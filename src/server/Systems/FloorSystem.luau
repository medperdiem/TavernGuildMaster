--!nonstrict
-- FloorSystem.luau — patrons, serve tasks, eavesdrop (spec §2, design doc §8b).
-- Patrons spawn seated, despawn on fade — no pathfinding (spec §7 ⚖).
-- Server owns patron state; the client renders NPCs at seat anchors.

local Data = script.Parent.Parent:WaitForChild("Data")
local Dialogue = require(Data:WaitForChild("Dialogue"))
local Heroes = require(Data:WaitForChild("Heroes"))
local Constants = require(Data:WaitForChild("Constants"))

local FloorSystem = {}

-- session.patrons = { [patronId] = { seat, wantsServe, whisper, expiresAt, chatter } }
function FloorSystem.init(session)
	session.patrons = {}
	session.nextPatronId = 1
	session.nextPatronAt = os.time() + 10
end

local function patronCount(session)
	local count = 0
	for _ in pairs(session.patrons) do
		count += 1
	end
	return count
end

FloorSystem.patronCount = patronCount

-- Compose an eavesdrop line; quirk hints about queue prospects inject here
-- (spec §7 step 6: "an eavesdrop names a queue prospect's quirk category").
local function rollWhisper(session, rng)
	local data = session.data
	local prospects = {}
	for _, prospect in pairs(data.queue) do
		table.insert(prospects, prospect)
	end
	if #prospects > 0 and rng:NextNumber() < 0.5 then
		local prospect = prospects[rng:NextInteger(1, #prospects)]
		local quirk = Heroes.Quirks[prospect.quirkId]
		local name = Heroes.get(prospect.archetype).name
		return string.format(Dialogue.Floor.eavesdropQuirk, name .. " " .. quirk.hint)
	end
	local pool = Dialogue.Floor.eavesdropFlavor
	return pool[rng:NextInteger(1, #pool)]
end

-- Tick the spawner. Returns { spawned = {...}, despawned = {...} } patron deltas.
function FloorSystem.tick(session, rng, act)
	local now = os.time()
	local spawned, despawned = {}, {}

	for patronId, patron in pairs(session.patrons) do
		if patron.expiresAt <= now then
			session.patrons[patronId] = nil
			table.insert(despawned, patronId)
		end
	end

	if now >= (session.nextPatronAt or 0) and patronCount(session) < Constants.PATRON_MAX then
		local patronId = "patron" .. session.nextPatronId
		session.nextPatronId += 1
		local chatterPool = act >= 2 and Dialogue.PatronChatter.act2 or Dialogue.PatronChatter.act1
		local patron = {
			id = patronId,
			seat = rng:NextInteger(1, Constants.PATRON_MAX),
			wantsServe = rng:NextNumber() < 0.6,
			order = Dialogue.Floor.orders[rng:NextInteger(1, #Dialogue.Floor.orders)],
			whisper = rng:NextNumber() < Constants.EAVESDROP_CHANCE and rollWhisper(session, rng) or nil,
			chatter = chatterPool[rng:NextInteger(1, #chatterPool)],
			expiresAt = now + rng:NextInteger(Constants.PATRON_LINGER_SEC[1], Constants.PATRON_LINGER_SEC[2]),
		}
		session.patrons[patronId] = patron
		table.insert(spawned, patron)
		session.nextPatronAt = now + rng:NextInteger(Constants.PATRON_SPAWN_SEC[1], Constants.PATRON_SPAWN_SEC[2])
	end

	return spawned, despawned
end

-- Player serves a patron. Returns payout line data or nil.
function FloorSystem.serve(session, patronId, HeroSystemRef)
	local patron = session.patrons[patronId]
	if not patron or not patron.wantsServe then
		return nil
	end
	patron.wantsServe = false
	session.data.gold += Constants.FLOOR_INCOME_PER_SERVE
	-- Stew on the floor feeds the kitchen quirks (Bram, Alduin).
	local quirkFired = HeroSystemRef.onStewServed(session.data)
	return {
		gold = Constants.FLOOR_INCOME_PER_SERVE,
		bark = Dialogue.Floor.fastService,
		quirkFired = quirkFired,
	}
end

-- Player eavesdrops. Returns the whisper (once) or nil.
function FloorSystem.eavesdrop(session, patronId)
	local patron = session.patrons[patronId]
	if not patron or not patron.whisper then
		return nil
	end
	local whisper = patron.whisper
	patron.whisper = nil
	return whisper
end

return FloorSystem
