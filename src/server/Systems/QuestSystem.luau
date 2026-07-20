--!nonstrict
-- QuestSystem.luau — assembly, board, odds, timers, ravens, beat resolution (spec §4, §7).
-- Quests are simulated (timers + beats) — no 3D regions. Beats are computed, then
-- NARRATED in the return report. Ravens fire at fixed fractions of quest duration.

local HttpService = game:GetService("HttpService")

local Data = script.Parent.Parent:WaitForChild("Data")
local QuestTables = require(Data:WaitForChild("QuestTables"))
local Dialogue = require(Data:WaitForChild("Dialogue"))
local Constants = require(Data:WaitForChild("Constants"))

local Systems = script.Parent
local HeroSystem = require(Systems:WaitForChild("HeroSystem"))

local QuestSystem = {}

local function pick(list, rng)
	return list[rng:NextInteger(1, #list)]
end

-- ============================================================
-- Assembly (quest doc §0): VERB + SUBJECT + ANTAGONIST + LOCATION + twists.
-- ============================================================
function QuestSystem.assemble(regionKey, rng)
	local region = QuestTables.Regions[regionKey]
	assert(region and region.unlocked, "region locked: " .. tostring(regionKey))

	local verbKey = pick(QuestTables.VerbOrder, rng)
	local verb = QuestTables.Verbs[verbKey]
	local subject = pick(region.subjects, rng)
	local antagonist = pick(region.antagonists, rng)
	local location = pick(region.locations, rng)

	-- Twist roll (Thornwood: 0–1)
	local twists = {}
	local twistCount = rng:NextInteger(region.twistCount[1], region.twistCount[2])
	local legal = QuestTables.ThornwoodTwists
	for _ = 1, twistCount do
		local twistKey = pick(legal, rng)
		if not table.find(twists, twistKey) then
			table.insert(twists, twistKey)
		end
	end

	local difficulty = region.tier + antagonist.rank + #twists

	-- Posting text: "{VERB phrase} — {antagonist hint / leaked twist hint}."
	local body
	if verb.antagonistLead then
		body = string.format(verb.phrase, antagonist.name, location)
	elseif verb.antagonistSecond then
		body = string.format(verb.phrase, subject, antagonist.name)
	else
		body = string.format(verb.phrase, subject, location)
	end
	local hintParts = {}
	local demandHint = region.hints[antagonist.primaryAxis]
	if demandHint then
		table.insert(hintParts, demandHint)
	end
	for _, twistKey in ipairs(twists) do
		local twist = QuestTables.Twists[twistKey]
		if twist.leak == "H" and twist.hint then
			table.insert(hintParts, twist.hint)
		end
	end
	local hint = #hintParts > 0 and table.concat(hintParts, "; ") or nil
	local text = body .. (hint and (" — " .. hint .. ".") or ".")

	local rewardBase = Constants.QUEST_REWARD_BASE * difficulty
	return {
		id = HttpService:GenerateGUID(false),
		region = regionKey,
		verb = verbKey,
		subject = subject,
		antagonist = antagonist,
		location = location,
		twists = twists,
		difficulty = difficulty,
		rewardMin = math.floor(rewardBase * 0.8),
		rewardMax = math.floor(rewardBase * Constants.OVERREACH_GAP_MULT),
		hint = hint,
		text = text,
		giver = pick(QuestTables.QuestGivers, rng),
	}
end

-- Fill the job board up to BOARD_POSTING_COUNT.
function QuestSystem.refreshBoard(session, rng)
	session.board = session.board or {}
	local count = 0
	for _ in pairs(session.board) do
		count += 1
	end
	while count < Constants.BOARD_POSTING_COUNT do
		local posting = QuestSystem.assemble("thornwood", rng)
		session.board[posting.id] = posting
		count += 1
	end
	session.boardRefreshedAt = os.time()
end

-- ============================================================
-- Odds band (spec §5): live supply-vs-demand readout, band not math.
-- ============================================================
function QuestSystem.oddsBand(data, posting, heroIds)
	if #heroIds == 0 then
		return "Empty"
	end
	local supply = HeroSystem.partySupply(data, heroIds)
	local antagonist = posting.antagonist
	local demand = antagonist.rank + QuestTables.Regions[posting.region].tier
	local margin = supply[antagonist.primaryAxis] + (Constants.BEAT_DIE + 1) / 2 - demand
	if margin >= 2 then
		return "Favored"
	elseif margin >= -1 then
		return "Even"
	end
	return "Risky"
end

-- ============================================================
-- Launch: validate party, start timers, schedule ravens.
-- ============================================================
function QuestSystem.launch(session, postingId, heroIds, rng)
	local data = session.data
	local posting = session.board and session.board[postingId]
	if not posting then
		return nil, "posting gone"
	end
	if #heroIds < 1 or #heroIds > Constants.PARTY_SIZE_MAX then
		return nil, "party size"
	end
	local seen = {}
	for _, id in ipairs(heroIds) do
		local hero = data.heroes[id]
		if not hero or hero.state ~= "idle" or seen[id] then
			return nil, "hero unavailable"
		end
		seen[id] = true
	end
	for _, id in ipairs(heroIds) do
		data.heroes[id].state = "questing"
	end
	session.board[postingId] = nil

	local duration = posting.scriptedDuration
		or rng:NextInteger(Constants.QUEST_DURATION_SEC[1], Constants.QUEST_DURATION_SEC[2])
	local now = os.time()
	local ravenPlan = {}
	for _, fraction in ipairs(Constants.RAVEN_AT_FRACTIONS) do
		table.insert(ravenPlan, now + math.floor(duration * fraction))
	end

	local quest = {
		id = posting.id,
		spec = posting,
		heroIds = heroIds,
		startedAt = now,
		endsAt = now + duration,
		ravenPlan = ravenPlan,
		firedRavens = 0,
		pendingRaven = nil,
		modifiers = { die = Constants.BEAT_DIE, demand = 0, reward = 1, rep = 0, injuryRisk = 0 },
		removedTwists = {},
		lastRavenType = nil,
		choices = {},
	}
	data.activeQuests[quest.id] = quest
	return quest
end

-- ============================================================
-- Raven selection: character > twist reveal > risk fork; never two of the
-- same type back-to-back (quest doc §4 generator rules).
-- ============================================================
local CharacterTriggers = {
	farmhand = function(quest, data, session)
		local _ = data
		return session.lastOdds and session.lastOdds[quest.id] == "Risky" -- low party confidence
	end,
	minstrel = function(quest)
		return quest.spec.verb == "NEGOTIATE"
	end,
	rogue = function(quest)
		return quest.spec.verb == "RETRIEVE"
	end,
	cleric = function(quest)
		return table.find(quest.spec.twists, "cursed_ground") ~= nil
	end,
	barbarian = function(quest)
		return table.find(quest.spec.antagonist.tags, "fear") ~= nil
	end,
	gourmet_knight = function(quest)
		return quest.spec.verb == "NEGOTIATE"
	end,
}

local function pickCharacterRaven(quest, session, rng)
	local data = session.data
	local candidates = {}
	for _, heroId in ipairs(quest.heroIds) do
		local hero = data.heroes[heroId]
		local trigger = hero and CharacterTriggers[hero.archetype]
		local pack = hero and Dialogue.forHero(hero.archetype)
		if trigger and pack and pack.raven and trigger(quest, data, session) then
			-- Freshness rule: a hero's raven never fires twice in a row across quests.
			if session.lastCharacterRaven ~= hero.archetype then
				table.insert(candidates, { heroId = heroId, archetype = hero.archetype, raven = pack.raven })
			end
		end
	end
	if #candidates == 0 then
		return nil
	end
	return candidates[rng:NextInteger(1, #candidates)]
end

local function pickRevealRaven(quest)
	for _, twistKey in ipairs(quest.spec.twists) do
		if not quest.removedTwists[twistKey] then
			local twist = QuestTables.Twists[twistKey]
			if twist.revealRaven and not quest.revealedTwist then
				return twistKey, QuestTables.RevealRavens[twist.revealRaven]
			end
		end
	end
	return nil
end

local function leaderName(quest, data)
	local hero = data.heroes[quest.heroIds[1]]
	return hero and hero.name or "the party"
end

-- Fire the next scheduled raven if due. Returns a client payload or nil.
function QuestSystem.maybeFireRaven(session, quest, rng)
	if quest.pendingRaven then
		return nil -- never stacks two (spec §5)
	end
	local nextIndex = quest.firedRavens + 1
	local dueAt = quest.ravenPlan[nextIndex]
	if not dueAt or os.time() < dueAt then
		return nil
	end
	quest.firedRavens = nextIndex

	local data = session.data
	local raven
	local character = pickCharacterRaven(quest, session, rng)
	if character and quest.lastRavenType ~= "character" then
		raven = {
			kind = "character",
			archetype = character.archetype,
			heroId = character.heroId,
			text = character.raven.text,
			options = character.raven.options,
			auto = 2, -- character ravens auto-take their safe option
		}
		session.lastCharacterRaven = character.archetype
	else
		local twistKey, reveal = pickRevealRaven(quest)
		if reveal and quest.lastRavenType ~= "reveal" then
			raven = {
				kind = "reveal",
				twistKey = twistKey,
				text = reveal.text,
				options = reveal.options,
				auto = reveal.auto,
			}
			quest.revealedTwist = twistKey
		else
			local forks = QuestTables.RiskForks[quest.spec.verb]
			if forks then
				local fork = forks[rng:NextInteger(1, #forks)]
				raven = {
					kind = "risk",
					text = string.format(fork.text, leaderName(quest, data)),
					options = fork.options,
					auto = fork.auto,
				}
			end
		end
	end
	if not raven then
		return nil
	end
	quest.lastRavenType = raven.kind
	raven.questId = quest.id
	raven.expiresAt = os.time() + Constants.RAVEN_EXPIRY_SEC
	quest.pendingRaven = raven
	return raven
end

-- Apply the chosen (or auto-resolved) raven option's effects to the quest.
local function applyEffects(quest, data, effects, heroId)
	for _, effect in ipairs(effects) do
		local mods = quest.modifiers
		if effect == "widen" then
			mods.die = 8
		elseif effect == "safe" then
			mods.demand -= 1
		elseif effect == "risk_up" or effect == "demand_up" then
			mods.demand += 1
		elseif effect == "slow" then
			quest.endsAt += math.floor((quest.endsAt - quest.startedAt) * 0.15)
		elseif effect == "fast" then
			quest.endsAt -= math.floor((quest.endsAt - quest.startedAt) * 0.15)
		elseif effect == "gold_up" then
			mods.reward *= 1.25
		elseif effect == "gold_down" then
			mods.reward *= 0.75
		elseif effect == "rep_up" then
			mods.rep += 1
		elseif effect == "rep_down" or effect == "honesty_ding" then
			mods.rep -= 1
		elseif effect == "injury_risk" then
			mods.injuryRisk += 0.15
		elseif effect == "fatigue" then
			for _, id in ipairs(quest.heroIds) do
				local hero = data.heroes[id]
				if hero then
					hero.flags.fatigued = true
				end
			end
		elseif effect == "cleanse" then
			for _, twistKey in ipairs(quest.spec.twists) do
				quest.removedTwists[twistKey] = true
			end
			quest.endsAt += math.floor((quest.endsAt - quest.startedAt) * 0.2)
		elseif effect == "presence_path" then
			quest.forcedComplicationAxis = "PRESENCE"
		elseif effect == "guile_path" then
			quest.forcedComplicationAxis = "GUILE"
		elseif effect == "rep_swing" then
			mods.rep += 2 -- doubled both ways; resolution flips sign on loss
			mods.repSwing = true
		end
	end
	local _ = heroId
end

-- Player answered a raven (or expiry auto-resolves it via optionIndex = raven.auto).
function QuestSystem.resolveRaven(session, questId, optionIndex, expired)
	local data = session.data
	local quest = data.activeQuests[questId]
	if not quest or not quest.pendingRaven then
		return nil
	end
	local raven = quest.pendingRaven
	local option = raven.options[optionIndex]
	if not option then
		return nil
	end
	quest.pendingRaven = nil
	table.insert(quest.choices, string.format("[%s] %s", raven.kind, option.text))

	applyEffects(quest, data, option.effects or (option.effect and { option.effect } or {}), raven.heroId)

	local reply = option.reply
	if raven.kind == "character" and raven.heroId then
		local hero = data.heroes[raven.heroId]
		if hero then
			if option.loyaltyTick then
				HeroSystem.addLoyalty(hero, Constants.LOYALTY_QUIRK_TICK)
			end
			if option.flagSet then
				hero.flags[option.flagSet] = true
			end
		end
	end
	if expired then
		local template = Dialogue.NeutralAutoResolutions[1]
		reply = string.format(template, leaderName(quest, data))
	end
	return { reply = reply, expired = expired or false }
end

-- ============================================================
-- Beat resolution (spec §4). APPROACH → 1–2 COMPLICATIONS → CLIMAX.
-- One die per beat; outcome ladder mapped from beat results.
-- ============================================================
function QuestSystem.resolve(session, quest, rng)
	local data = session.data
	local spec = quest.spec
	local antagonist = spec.antagonist
	local regionTier = QuestTables.Regions[spec.region].tier
	local supply = HeroSystem.partySupply(data, quest.heroIds)
	local mods = quest.modifiers
	local die = mods.die or Constants.BEAT_DIE

	local beats = {}
	local function runBeat(kind, axis, demand)
		local roll = rng:NextInteger(1, die)
		local total = (supply[axis] or 0) + roll
		local won = total >= demand
		table.insert(beats, {
			kind = kind,
			axis = axis,
			won = won,
			margin = total - demand,
			narration = Dialogue.BeatNarration[kind == "COMPLICATION" and "COMPLICATION" or kind][won and "won" or "lost"],
		})
		return won, total - demand
	end

	local baseDemand = antagonist.rank + regionTier + (mods.demand or 0)

	-- APPROACH tests the secondary axis at reduced demand.
	runBeat("APPROACH", antagonist.secondaryAxis, baseDemand - 1)

	-- COMPLICATIONS: one per live twist (twist axis), else one on a random axis.
	local complicationCount = 0
	for _, twistKey in ipairs(spec.twists) do
		if not quest.removedTwists[twistKey] then
			local twist = QuestTables.Twists[twistKey]
			local axis = quest.forcedComplicationAxis or twist.axis
			runBeat("COMPLICATION", axis, baseDemand + twist.demandMod - 1)
			complicationCount += 1
		end
	end
	if complicationCount == 0 then
		local axis = quest.forcedComplicationAxis
			or (rng:NextInteger(1, 2) == 1 and antagonist.primaryAxis or antagonist.secondaryAxis)
		runBeat("COMPLICATION", axis, baseDemand - 1)
	end

	-- CLIMAX tests the primary axis at full demand.
	local climaxWon, climaxMargin = runBeat("CLIMAX", antagonist.primaryAxis, baseDemand)

	local wonCount = 0
	for _, beat in ipairs(beats) do
		if beat.won then
			wonCount += 1
		end
	end

	local outcome
	if spec.forcedOutcome then
		outcome = spec.forcedOutcome -- FTUE scripted beats (spec §7 step 8)
	elseif climaxWon and wonCount == #beats and climaxMargin >= 3 then
		outcome = "Triumph"
	elseif climaxWon then
		outcome = "Success"
	elseif wonCount >= 1 then
		outcome = "Setback"
	else
		outcome = "Disaster"
	end

	-- Rewards: difficulty × party-gap multiplier (punching up pays — design doc §4.3).
	local partyPower = 0
	for _, id in ipairs(quest.heroIds) do
		local hero = data.heroes[id]
		if hero then
			partyPower += hero.tier + (hero.gearBonus or 0)
		end
	end
	local bandsAbove = math.clamp(spec.difficulty - partyPower, 0, 3)
	local gapMult = Constants.OVERREACH_GAP_MULT ^ bandsAbove
	local gold = 0
	if outcome == "Triumph" then
		gold = math.floor(Constants.QUEST_REWARD_BASE * spec.difficulty * gapMult * (mods.reward or 1) * 1.3)
	elseif outcome == "Success" then
		gold = math.floor(Constants.QUEST_REWARD_BASE * spec.difficulty * gapMult * (mods.reward or 1))
	elseif outcome == "Setback" then
		gold = math.floor(Constants.QUEST_REWARD_BASE * spec.difficulty * (mods.reward or 1) * 0.4)
	end
	data.gold += gold

	-- Reputation accrues silently in S1 (cap + bond mechanics run, UI is S2 — spec §10).
	local today = math.floor(os.time() / 86400)
	if data.repQuestsDay ~= today then
		data.repQuestsDay = today
		data.repQuestsToday = 0
	end
	local repDelta = 0
	if outcome == "Triumph" or outcome == "Success" then
		if data.repQuestsToday < Constants.REP_QUESTS_PER_DAY then
			local bond = Constants.REP_QUEST_BOND_PER_DIFF * spec.difficulty
			if data.gold >= bond then
				-- Bond is staked and returned with the win; only the rep flows in S1.
				data.repQuestsToday += 1
				repDelta = spec.difficulty
			end
		end
	end
	repDelta += (mods.rep or 0)
	if mods.repSwing and outcome ~= "Triumph" and outcome ~= "Success" then
		repDelta = -math.abs(repDelta)
	end
	data.reputation.score = math.max(0, data.reputation.score + repDelta)

	-- Hero states, injuries, loyalty, return lines.
	local heroLines, injuries = {}, {}
	for _, id in ipairs(quest.heroIds) do
		local hero = data.heroes[id]
		if hero then
			hero.state = "idle"
			hero.flags.fatigued = nil
			local pack = Dialogue.forHero(hero.archetype)
			local line = pack and pack.returns and pack.returns[outcome]
			if outcome == "Triumph" then
				HeroSystem.addLoyalty(hero, Constants.LOYALTY_QUEST_TRIUMPH)
			elseif outcome == "Success" then
				HeroSystem.addLoyalty(hero, Constants.LOYALTY_QUEST_SUCCESS)
			elseif outcome == "Disaster" then
				HeroSystem.addLoyalty(hero, Constants.LOYALTY_QUEST_DISASTER)
				hero.flags.survived_disaster = true
			end
			if outcome == "Setback" or outcome == "Disaster" then
				local chance = (outcome == "Disaster" and Constants.INJURY_CHANCE_DISASTER or Constants.INJURY_CHANCE_SETBACK)
					+ (mods.injuryRisk or 0)
				if rng:NextNumber() < chance then
					HeroSystem.injure(data, id, rng)
					table.insert(injuries, hero.name)
				end
				if hero.archetype == "farmhand" and not hero.flags.first_setback then
					hero.flags.first_setback = true -- hour-one anchor: "Worth it, boss."
				end
			end
			table.insert(heroLines, { name = hero.name, line = line })
		end
	end

	data.activeQuests[quest.id] = nil

	return {
		questId = quest.id,
		posting = spec.text,
		outcome = outcome,
		gold = gold,
		rep = repDelta,
		beats = beats,
		heroLines = heroLines,
		injuries = injuries,
		choices = quest.choices,
	}
end

-- ============================================================
-- Login catch-up (spec §3 ⚖): quests that finished while away resolve NOW,
-- expired ravens taking their auto options. Returns the reports for the haul.
-- ============================================================
function QuestSystem.catchUp(session, rng)
	local data = session.data
	local now = os.time()
	local reports = {}
	for questId, quest in pairs(data.activeQuests) do
		if quest.endsAt <= now then
			-- Fire and auto-resolve every raven the quest would have sent.
			while quest.firedRavens < #quest.ravenPlan do
				-- maybeFireRaven advances firedRavens itself; nil = no raven fit that slot.
				local raven = QuestSystem.maybeFireRaven(session, quest, rng)
				if raven then
					QuestSystem.resolveRaven(session, questId, raven.auto or 2, true)
				end
			end
			if quest.pendingRaven then
				QuestSystem.resolveRaven(session, questId, quest.pendingRaven.auto or 2, true)
			end
			table.insert(reports, QuestSystem.resolve(session, quest, rng))
		end
	end
	return reports
end

return QuestSystem
