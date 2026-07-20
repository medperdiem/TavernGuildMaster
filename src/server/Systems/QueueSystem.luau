--!nonstrict
-- QueueSystem.luau — prospect rolls, seat timers, interviews (spec §2, design doc §6).
-- Interviews are strictly choice-based (spec §8): no free text anywhere.

local Data = script.Parent.Parent:WaitForChild("Data")
local Heroes = require(Data:WaitForChild("Heroes"))
local Dialogue = require(Data:WaitForChild("Dialogue"))
local Constants = require(Data:WaitForChild("Constants"))

local Systems = script.Parent
local HeroSystem = require(Systems:WaitForChild("HeroSystem"))

local QueueSystem = {}

local function rosterHas(data, archetype)
	for _, hero in pairs(data.heroes) do
		if hero.archetype == archetype then
			return true
		end
	end
	return false
end

local function seatedHas(data, archetype)
	for _, prospect in pairs(data.queue) do
		if prospect.archetype == archetype then
			return true
		end
	end
	return false
end

local function occupiedSeats(data)
	local count = 0
	for _ in pairs(data.queue) do
		count += 1
	end
	return count
end

-- Weighted roll of an archetype not already signed or seated. nil if roster complete.
local function rollArchetype(data, rng)
	local pool, totalWeight = {}, 0
	for _, key in ipairs(Heroes.QueueRollOrder) do
		if not rosterHas(data, key) and not seatedHas(data, key) then
			local weight = Heroes.get(key).signWeight
			table.insert(pool, { key = key, weight = weight })
			totalWeight += weight
		end
	end
	if totalWeight == 0 then
		return nil
	end
	local roll = rng:NextInteger(1, totalWeight)
	for _, entry in ipairs(pool) do
		roll -= entry.weight
		if roll <= 0 then
			return entry.key
		end
	end
	return pool[#pool].key
end

-- Drop expired prospects; returns count removed.
function QueueSystem.expireSeats(data)
	local now, removed = os.time(), 0
	for seatId, prospect in pairs(data.queue) do
		if prospect.expiresAt <= now then
			data.queue[seatId] = nil
			removed += 1
		end
	end
	return removed
end

-- Fill empty seats with fresh prospects (commons always trickle in — design doc §6).
-- FTUE gates arrivals until the scripted beats have played (spec §7 step 8).
function QueueSystem.fillSeats(data, rng)
	local arrivals = {}
	if data.ftue.step < 4 then
		return arrivals -- hour-one spawns are scripted by FTUESystem
	end
	for seat = 1, Constants.QUEUE_SEATS do
		local seatId = "seat" .. seat
		if not data.queue[seatId] and occupiedSeats(data) < Constants.QUEUE_SEATS then
			local archetype = rollArchetype(data, rng)
			if archetype then
				data.queue[seatId] = HeroSystem.rollProspect(archetype, rng)
				table.insert(arrivals, seatId)
			end
		end
	end
	return arrivals
end

-- Place a specific prospect in a specific seat (FTUE scripted arrivals).
function QueueSystem.placeScripted(data, seatId, archetype, rng)
	data.queue[seatId] = HeroSystem.rollProspect(archetype, rng)
	return data.queue[seatId]
end

-- ============================================================
-- Interview state machine. One interview at a time per player.
-- session.interview = { seatId, nodeIndex, flags, asksLeft, awaitingDecision }
-- ============================================================

local function interviewPack(prospect)
	local pack = Dialogue.forHero(prospect.archetype)
	return pack and pack.interview or nil
end

-- Begin the interview. Returns a client payload or nil, reason.
function QueueSystem.startInterview(session, seatId, patronCount)
	local data = session.data
	local prospect = data.queue[seatId]
	if not prospect then
		return nil, "empty seat"
	end
	-- Vex's quirk fires HERE, as a teaching moment: she won't talk to a crowded room.
	-- Suppressed during the scripted hour so the first-choice beat can't dead-end.
	if data.ftue.step >= 4 and prospect.quirkId == "hates_crowds" and (patronCount or 0) > 3 then
		data.queue[seatId] = nil
		local pack = Dialogue.forHero(prospect.archetype)
		return nil, pack.quirkLines.prospect_blocked
	end
	local interview = interviewPack(prospect)
	if not interview then
		return nil, "no script"
	end
	session.interview = {
		seatId = seatId,
		nodeIndex = 1,
		flags = {},
		asksLeft = 2,
		awaitingDecision = false,
	}
	local def = Heroes.get(prospect.archetype)
	return {
		archetype = prospect.archetype,
		name = def.name,
		rarity = def.rarity,
		revealedPref = prospect.revealedPref,
		cost = Constants.RECRUIT_COST[def.rarity],
		approach = interview.approach,
		node = interview.nodes[1],
	}
end

-- Apply a choice on the current node. Returns { reply, node?, phase }.
function QueueSystem.choose(session, choiceIndex)
	local state = session.interview
	if not state or state.awaitingDecision then
		return nil
	end
	local prospect = session.data.queue[state.seatId]
	if not prospect then
		session.interview = nil
		return nil
	end
	local interview = interviewPack(prospect)
	local node = interview.nodes[state.nodeIndex]
	local option = node and node.options[choiceIndex]
	if not option then
		return nil
	end
	if option.flag then
		state.flags[option.flag] = true
	end
	state.nodeIndex += 1
	local nextNode = interview.nodes[state.nodeIndex]
	if nextNode then
		return { reply = option.reply, node = nextNode, phase = "questions" }
	end
	state.awaitingDecision = true
	return { reply = option.reply, phase = "ask" }
end

-- Player asks one of their questions ("What do you want?" etc. — spec §6).
function QueueSystem.ask(session, which)
	local state = session.interview
	if not state or not state.awaitingDecision or state.asksLeft <= 0 then
		return nil
	end
	local prospect = session.data.queue[state.seatId]
	if not prospect then
		return nil
	end
	local interview = interviewPack(prospect)
	local line = interview.ask and interview.ask[which]
	if not line then
		return nil
	end
	state.asksLeft -= 1
	return { reply = line, asksLeft = state.asksLeft }
end

-- Final decision: sign or let them think. Returns result payload.
function QueueSystem.decide(session, decision, rng)
	local state = session.interview
	if not state then
		return nil
	end
	local data = session.data
	local prospect = data.queue[state.seatId]
	session.interview = nil
	if not prospect then
		return nil
	end
	local interview = interviewPack(prospect)
	if decision ~= "sign" then
		return { signed = false, line = interview.walkAway or Dialogue.GenericInterview.walkAway }
	end
	local def = Heroes.get(prospect.archetype)
	local cost = Constants.RECRUIT_COST[def.rarity]
	-- FTUE Bram signs free: the uncle "left his mark held" (hour-one guardrail).
	if data.ftue.step <= 1 and prospect.archetype == "farmhand" then
		cost = 0
	end
	if data.gold < cost then
		return { signed = false, line = "Come back when the coin's real.", reason = "gold" }
	end
	data.gold -= cost
	local suspicious = state.flags.lied_interview == true
	local heroId = HeroSystem.signHero(data, prospect, suspicious)
	local hero = data.heroes[heroId]
	for flag in pairs(state.flags) do
		hero.flags[flag] = true
	end
	data.queue[state.seatId] = nil
	local _ = rng -- reserved: negotiate counter-offers arrive with Slice 2
	return {
		signed = true,
		heroId = heroId,
		line = interview.sign or Dialogue.GenericInterview.sign,
		suspicious = suspicious,
	}
end

return QueueSystem
