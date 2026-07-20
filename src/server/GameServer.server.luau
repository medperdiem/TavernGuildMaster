--!nonstrict
-- GameServer.server.luau — boot, join/leave, save/load, the main loop (spec §2, §3).
-- Server-authoritative everything: client renders and requests; server owns state.
--
-- NOTE (Slice 1): set the experience to ONE player per server in Game Settings.
-- The tavern is a shared 3D space; tavern visiting arrives with PvP in Slice 3.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = script:WaitForChild("Data")
local Constants = require(Data:WaitForChild("Constants"))
local Heroes = require(Data:WaitForChild("Heroes"))
local Dialogue = require(Data:WaitForChild("Dialogue"))

local Systems = script:WaitForChild("Systems")
local HeroSystem = require(Systems:WaitForChild("HeroSystem"))
local QueueSystem = require(Systems:WaitForChild("QueueSystem"))
local QuestSystem = require(Systems:WaitForChild("QuestSystem"))
local EconomySystem = require(Systems:WaitForChild("EconomySystem"))
local FloorSystem = require(Systems:WaitForChild("FloorSystem"))
local FTUESystem = require(Systems:WaitForChild("FTUESystem"))
local TavernBuilder = require(Systems:WaitForChild("TavernBuilder"))

local RemoteNames = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RemoteNames"))

local DATA_VERSION = 1
local STORE_NAME = "PlayerData_v1"

-- ============================================================
-- Remotes
-- ============================================================
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = RemoteNames.Folder
remotesFolder.Parent = ReplicatedStorage

local Remotes = {}
local function makeRemote(name, isFunction)
	local remote = Instance.new(isFunction and "RemoteFunction" or "RemoteEvent")
	remote.Name = name
	remote.Parent = remotesFolder
	Remotes[name] = remote
	return remote
end
for _, name in
	ipairs({
		RemoteNames.StateSync,
		RemoteNames.RavenEvent,
		RemoteNames.QuestReport,
		RemoteNames.WelcomeBack,
		RemoteNames.InterviewUpdate,
		RemoteNames.FloorEvent,
		RemoteNames.Notify,
		RemoteNames.FtueEvent,
		RemoteNames.StartInterview,
		RemoteNames.InterviewChoice,
		RemoteNames.InterviewAsk,
		RemoteNames.InterviewDecide,
		RemoteNames.LaunchQuest,
		RemoteNames.RavenChoice,
		RemoteNames.ServePatron,
		RemoteNames.Eavesdrop,
		RemoteNames.HealHero,
		RemoteNames.TalkToHero,
		RemoteNames.FtueAdvance,
	})
do
	makeRemote(name, false)
end
makeRemote(RemoteNames.RequestOdds, true)

-- ============================================================
-- Tavern shell
-- ============================================================
local anchors = TavernBuilder.build()
local npcFolder = Instance.new("Folder")
npcFolder.Name = "NPCs"
npcFolder.Parent = anchors.tavern

-- ============================================================
-- Save / load (UpdateAsync, version field, BindToClose flush — spec §3)
-- ============================================================
local store
pcall(function()
	store = DataStoreService:GetDataStore(STORE_NAME)
end)

local function freshData()
	return {
		version = DATA_VERSION,
		gold = Constants.STARTING_GOLD,
		reputation = { score = 0, record = { contractsBroken = 0, poachesDefended = 0, questsAbandoned = 0 } },
		heroes = {},
		queue = {},
		activeQuests = {},
		tavern = { decor = {}, upgrades = { kitchen = 0 } },
		lastSeenAt = 0,
		ftue = { step = 0 },
		repQuestsToday = 0,
		repQuestsDay = 0,
	}
end

local function migrate(data)
	-- version field from day one: hero flags and quest specs WILL change shape.
	if data.version == nil then
		data.version = DATA_VERSION
	end
	return data
end

local function loadData(player)
	if not store then
		return freshData()
	end
	local ok, stored = pcall(function()
		return store:GetAsync("p_" .. player.UserId)
	end)
	if ok and stored then
		return migrate(stored)
	end
	return freshData()
end

local Sessions = {}

local function saveData(player, isFinal)
	local session = Sessions[player]
	if not session or not store then
		return
	end
	if isFinal then
		session.data.lastSeenAt = os.time()
	end
	local snapshot = session.data
	pcall(function()
		store:UpdateAsync("p_" .. player.UserId, function()
			return snapshot
		end)
	end)
end

-- ============================================================
-- Client payload builders (never leak server-only tables wholesale)
-- ============================================================
local function questSummaries(data)
	local list = {}
	for id, quest in pairs(data.activeQuests) do
		table.insert(list, {
			id = id,
			text = quest.spec.text,
			endsAt = quest.endsAt,
			heroNames = (function()
				local names = {}
				for _, heroId in ipairs(quest.heroIds) do
					local hero = data.heroes[heroId]
					table.insert(names, hero and hero.name or "?")
				end
				return names
			end)(),
			hasRaven = quest.pendingRaven ~= nil,
		})
	end
	return list
end

local function boardPayload(session)
	local list = {}
	for id, posting in pairs(session.board or {}) do
		table.insert(list, {
			id = id,
			text = posting.text,
			difficulty = posting.difficulty,
			rewardMin = posting.rewardMin,
			rewardMax = posting.rewardMax,
			hint = posting.hint,
			giver = posting.giver,
			scripted = posting.scripted or false,
		})
	end
	table.sort(list, function(a, b)
		return a.difficulty < b.difficulty
	end)
	return list
end

local function queuePayload(data)
	local seats = {}
	for seatId, prospect in pairs(data.queue) do
		local def = Heroes.get(prospect.archetype)
		seats[seatId] = {
			archetype = prospect.archetype,
			name = def.name,
			rarity = def.rarity,
			revealedPref = prospect.revealedPref,
			expiresAt = prospect.expiresAt,
		}
	end
	return seats
end

local function heroesPayload(data)
	local roster = {}
	for id, hero in pairs(data.heroes) do
		roster[id] = {
			archetype = hero.archetype,
			name = hero.name,
			tier = hero.tier,
			tierName = Heroes.get(hero.archetype).tierNames[hero.tier],
			loyalty = hero.loyalty,
			register = HeroSystem.register(hero),
			state = hero.state,
			injuryEndsAt = hero.injuryEndsAt,
			quirkKnown = hero.quirkKnown,
			quirkHint = hero.quirkKnown and Heroes.Quirks[hero.quirkId].hint or nil,
			axes = Heroes.get(hero.archetype).axes,
			healCost = Constants.HEAL_COST_PER_INJURY,
		}
	end
	return roster
end

local function syncState(session)
	local data = session.data
	Remotes[RemoteNames.StateSync]:FireClient(session.player, {
		gold = data.gold,
		heroes = heroesPayload(data),
		queue = queuePayload(data),
		board = boardPayload(session),
		quests = questSummaries(data),
		ftueStep = data.ftue.step,
	})
end

-- ============================================================
-- NPC placeholders at seats (prospects, patrons, idle heroes)
-- ============================================================
local rebuildNpcs -- forward declaration: prompt handlers below need it

-- Open an interview for a seat: shared by ProximityPrompts and the remote.
local function openInterview(session, seatId)
	local player = session.player
	local payload, reason = QueueSystem.startInterview(session, seatId, FloorSystem.patronCount(session))
	if payload then
		Remotes[RemoteNames.InterviewUpdate]:FireClient(player, { phase = "open", payload = payload })
	else
		Remotes[RemoteNames.Notify]:FireClient(player, { kind = "info", text = reason or "They've gone." })
		syncState(session)
		rebuildNpcs(session)
	end
end

-- Heal an injured hero: shared by ProximityPrompts and the remote.
local function tryHeal(session, heroId)
	local player = session.player
	local ok, reason = HeroSystem.heal(session.data, heroId)
	if ok then
		local hero = session.data.heroes[heroId]
		Remotes[RemoteNames.Notify]:FireClient(player, { kind = "heal", name = hero.name, text = "Patched up. Rest does the last of it." })
	elseif reason then
		Remotes[RemoteNames.Notify]:FireClient(player, { kind = "info", text = reason })
	end
	syncState(session)
	rebuildNpcs(session)
end

local ARCHETYPE_COLORS = {
	farmhand = Color3.fromRGB(150, 110, 60),
	minstrel = Color3.fromRGB(150, 60, 130),
	rogue = Color3.fromRGB(60, 60, 70),
	cleric = Color3.fromRGB(220, 210, 180),
	barbarian = Color3.fromRGB(110, 70, 50),
	gourmet_knight = Color3.fromRGB(180, 160, 80),
}

rebuildNpcs = function(session)
	npcFolder:ClearAllChildren()
	local data = session.data

	-- Prospects at the bar seats.
	local seatIndex = 0
	for seatId, prospect in pairs(data.queue) do
		seatIndex += 1
		local seatModel = anchors.prospectSeats[math.min(seatIndex, #anchors.prospectSeats)]
		local position = seatModel.PrimaryPart.Position + Vector3.new(0, 0.5, 0)
		local def = Heroes.get(prospect.archetype)
		local npc = TavernBuilder.makeNpc(def.name, ARCHETYPE_COLORS[prospect.archetype] or Color3.new(0.5, 0.5, 0.5), position, npcFolder)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Interview " .. def.name
		prompt.ObjectText = "Prospect"
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = npc.PrimaryPart
		prompt.Triggered:Connect(function(player)
			if Sessions[player] == session then
				openInterview(session, seatId)
			end
		end)
		npc:SetAttribute("SeatId", seatId)
	end

	-- Idle / resting heroes by the hearth (fireside chats).
	local spotIndex = 0
	for heroId, hero in pairs(data.heroes) do
		if hero.state ~= "questing" and spotIndex < #anchors.heroSpots then
			spotIndex += 1
			local position = anchors.heroSpots[spotIndex].Position
			local label = hero.name .. (hero.state == "injured" and " (hurt)" or "")
			local npc = TavernBuilder.makeNpc(label, ARCHETYPE_COLORS[hero.archetype] or Color3.new(0.5, 0.5, 0.5), position, npcFolder)
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = hero.state == "injured" and "Tend to " .. hero.name or "Talk to " .. hero.name
			prompt.ObjectText = "Hero"
			prompt.MaxActivationDistance = 10
			prompt.RequiresLineOfSight = false
			prompt.Parent = npc.PrimaryPart
			prompt.Triggered:Connect(function(player)
				if Sessions[player] ~= session then
					return
				end
				if hero.state == "injured" then
					tryHeal(session, heroId)
				else
					local line = HeroSystem.firesideLine(hero, session.rng)
					if line then
						Remotes[RemoteNames.Notify]:FireClient(player, { kind = "fireside", name = hero.name, text = line })
					end
				end
			end)
		end
	end

	-- Patrons at table seats.
	for patronId, patron in pairs(session.patrons or {}) do
		local seatModel = anchors.patronSeats[patron.seat]
		if seatModel then
			local position = seatModel.PrimaryPart.Position + Vector3.new(0, 0.5, 0)
			local npc = TavernBuilder.makeNpc("Patron", Color3.fromRGB(100, 100, 110), position, npcFolder)
			if patron.wantsServe or patron.whisper then
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText = patron.wantsServe and "Serve" or "Listen in"
				prompt.ObjectText = patron.wantsServe and patron.order or "…whispering…"
				prompt.MaxActivationDistance = 8
				prompt.RequiresLineOfSight = false
				prompt.Parent = npc.PrimaryPart
				prompt.Triggered:Connect(function(player)
					local playerSession = Sessions[player]
					if not playerSession then
						return
					end
					if patron.wantsServe then
						local result = FloorSystem.serve(playerSession, patronId, HeroSystem)
						if result then
							Remotes[RemoteNames.Notify]:FireClient(player, { kind = "serve", text = result.bark, gold = result.gold })
							for _, heroId in ipairs(result.quirkFired) do
								local hero = playerSession.data.heroes[heroId]
								local pack = Dialogue.forHero(hero.archetype)
								Remotes[RemoteNames.Notify]:FireClient(player, { kind = "quirk", name = hero.name, text = pack.quirkLines.fired })
							end
							syncState(playerSession)
							rebuildNpcs(playerSession)
						end
					else
						local whisper = FloorSystem.eavesdrop(playerSession, patronId)
						if whisper then
							Remotes[RemoteNames.Notify]:FireClient(player, { kind = "eavesdrop", text = whisper })
							rebuildNpcs(playerSession)
						end
					end
				end)
			end
		end
	end
end

-- ============================================================
-- Join / leave
-- ============================================================
local function currentAct(data)
	return data.reputation.score >= 25 and 2 or 1
end

Players.PlayerAdded:Connect(function(player)
	local data = loadData(player)
	local session = {
		player = player,
		data = data,
		rng = Random.new(os.time() + player.UserId),
		board = {},
		patrons = {},
		interview = nil,
		lastOdds = {},
		lastCharacterRaven = nil,
		lastSaveAt = os.time(),
	}
	Sessions[player] = session
	FloorSystem.init(session)

	-- Login catch-up: finished quests resolve, ravens auto-resolve (spec §3 ⚖).
	local reports = QuestSystem.catchUp(session, session.rng)
	local offlineGold, awayHours = EconomySystem.offlineAccrual(data)
	local wagesPaid = EconomySystem.chargeWages(data)
	QueueSystem.expireSeats(data)
	local arrivals = QueueSystem.fillSeats(data, session.rng)
	HeroSystem.tickStates(data)

	local ftueEvent = FTUESystem.onJoin(session)
	if data.ftue.step >= 4 then
		QuestSystem.refreshBoard(session, session.rng)
	end

	-- Welcome-back screen only when there is actually a haul to show.
	if data.lastSeenAt > 0 and (awayHours > 0.05 or #reports > 0) then
		Remotes[RemoteNames.WelcomeBack]:FireClient(
			player,
			EconomySystem.welcomeBackSummary(data, offlineGold, reports, #arrivals, wagesPaid)
		)
	end
	for _, report in ipairs(reports) do
		FTUESystem.onQuestResolved(session, report)
	end
	if ftueEvent then
		Remotes[RemoteNames.FtueEvent]:FireClient(player, ftueEvent)
	end
	data.lastSeenAt = os.time()
	syncState(session)
	rebuildNpcs(session)
end)

Players.PlayerRemoving:Connect(function(player)
	saveData(player, true)
	Sessions[player] = nil
end)

game:BindToClose(function()
	for player in pairs(Sessions) do
		saveData(player, true)
	end
end)

-- ============================================================
-- Remote handlers (all inputs validated server-side)
-- ============================================================
local function sessionOf(player)
	return Sessions[player]
end

Remotes[RemoteNames.StartInterview].OnServerEvent:Connect(function(player, seatId)
	local session = sessionOf(player)
	if not session or type(seatId) ~= "string" then
		return
	end
	openInterview(session, seatId)
end)

Remotes[RemoteNames.InterviewChoice].OnServerEvent:Connect(function(player, choiceIndex)
	local session = sessionOf(player)
	if not session or type(choiceIndex) ~= "number" then
		return
	end
	local result = QueueSystem.choose(session, choiceIndex)
	if result then
		Remotes[RemoteNames.InterviewUpdate]:FireClient(player, { phase = result.phase, reply = result.reply, node = result.node })
	end
end)

Remotes[RemoteNames.InterviewAsk].OnServerEvent:Connect(function(player, which)
	local session = sessionOf(player)
	if not session or type(which) ~= "string" then
		return
	end
	local result = QueueSystem.ask(session, which)
	if result then
		Remotes[RemoteNames.InterviewUpdate]:FireClient(player, { phase = "ask", reply = result.reply, asksLeft = result.asksLeft })
	end
end)

Remotes[RemoteNames.InterviewDecide].OnServerEvent:Connect(function(player, decision)
	local session = sessionOf(player)
	if not session or type(decision) ~= "string" then
		return
	end
	local result = QueueSystem.decide(session, decision, session.rng)
	if not result then
		return
	end
	Remotes[RemoteNames.InterviewUpdate]:FireClient(player, { phase = "closed", reply = result.line, signed = result.signed })
	if result.signed then
		local hero = session.data.heroes[result.heroId]
		FTUESystem.onHeroSigned(session, hero.archetype)
	end
	syncState(session)
	rebuildNpcs(session)
end)

Remotes[RemoteNames.RequestOdds].OnServerInvoke = function(player, postingId, heroIds)
	local session = sessionOf(player)
	if not session or type(postingId) ~= "string" or type(heroIds) ~= "table" then
		return "?"
	end
	local posting = session.board[postingId]
	if not posting then
		return "?"
	end
	local band = QuestSystem.oddsBand(session.data, posting, heroIds)
	session.lastOdds[postingId] = band
	return band
end

Remotes[RemoteNames.LaunchQuest].OnServerEvent:Connect(function(player, postingId, heroIds)
	local session = sessionOf(player)
	if not session or type(postingId) ~= "string" or type(heroIds) ~= "table" then
		return
	end
	local cleanIds = {}
	for _, id in ipairs(heroIds) do
		if type(id) == "string" then
			table.insert(cleanIds, id)
		end
	end
	local quest, reason = QuestSystem.launch(session, postingId, cleanIds, session.rng)
	if not quest then
		Remotes[RemoteNames.Notify]:FireClient(player, { kind = "info", text = "Can't launch: " .. tostring(reason) })
		return
	end
	syncState(session)
	rebuildNpcs(session)
end)

Remotes[RemoteNames.RavenChoice].OnServerEvent:Connect(function(player, questId, optionIndex)
	local session = sessionOf(player)
	if not session or type(questId) ~= "string" or type(optionIndex) ~= "number" then
		return
	end
	local result = QuestSystem.resolveRaven(session, questId, optionIndex, false)
	if result and result.reply then
		Remotes[RemoteNames.Notify]:FireClient(player, { kind = "raven", text = result.reply })
	end
	syncState(session)
end)

Remotes[RemoteNames.HealHero].OnServerEvent:Connect(function(player, heroId)
	local session = sessionOf(player)
	if not session or type(heroId) ~= "string" then
		return
	end
	tryHeal(session, heroId)
end)

Remotes[RemoteNames.TalkToHero].OnServerEvent:Connect(function(player, heroId)
	local session = sessionOf(player)
	if not session or type(heroId) ~= "string" then
		return
	end
	local hero = session.data.heroes[heroId]
	if hero then
		local line = HeroSystem.firesideLine(hero, session.rng)
		if line then
			Remotes[RemoteNames.Notify]:FireClient(player, { kind = "fireside", name = hero.name, text = line })
		end
	end
end)

Remotes[RemoteNames.FtueAdvance].OnServerEvent:Connect(function(player)
	local session = sessionOf(player)
	if not session then
		return
	end
	if FTUESystem.acknowledge(session) then
		syncState(session)
		rebuildNpcs(session)
	end
end)

Remotes[RemoteNames.ServePatron].OnServerEvent:Connect(function(player, patronId)
	local session = sessionOf(player)
	if not session or type(patronId) ~= "string" then
		return
	end
	local result = FloorSystem.serve(session, patronId, HeroSystem)
	if result then
		Remotes[RemoteNames.Notify]:FireClient(player, { kind = "serve", text = result.bark, gold = result.gold })
		syncState(session)
		rebuildNpcs(session)
	end
end)

Remotes[RemoteNames.Eavesdrop].OnServerEvent:Connect(function(player, patronId)
	local session = sessionOf(player)
	if not session or type(patronId) ~= "string" then
		return
	end
	local whisper = FloorSystem.eavesdrop(session, patronId)
	if whisper then
		Remotes[RemoteNames.Notify]:FireClient(player, { kind = "eavesdrop", text = whisper })
		rebuildNpcs(session)
	end
end)

-- ============================================================
-- Main loop (1 Hz): quest timers, ravens, floor, queue, autosave
-- ============================================================
local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator < 1 then
		return
	end
	accumulator = 0
	local now = os.time()

	for player, session in pairs(Sessions) do
		local data = session.data
		local changed = false

		-- Raven expiry → neutral auto-resolution (spec §7 step 5).
		for questId, quest in pairs(data.activeQuests) do
			if quest.pendingRaven and quest.pendingRaven.expiresAt <= now then
				local result = QuestSystem.resolveRaven(session, questId, quest.pendingRaven.auto or 2, true)
				if result then
					Remotes[RemoteNames.Notify]:FireClient(player, { kind = "raven", text = result.reply })
					changed = true
				end
			end
		end

		-- Fire due ravens.
		for _, quest in pairs(data.activeQuests) do
			if now < quest.endsAt then
				local raven = QuestSystem.maybeFireRaven(session, quest, session.rng)
				if raven then
					Remotes[RemoteNames.RavenEvent]:FireClient(player, raven)
					changed = true
				end
			end
		end

		-- Resolve finished quests.
		for questId, quest in pairs(data.activeQuests) do
			if now >= quest.endsAt then
				if quest.pendingRaven then
					QuestSystem.resolveRaven(session, questId, quest.pendingRaven.auto or 2, true)
				end
				local report = QuestSystem.resolve(session, quest, session.rng)
				Remotes[RemoteNames.QuestReport]:FireClient(player, report)
				FTUESystem.onQuestResolved(session, report)
				if session.data.ftue.step >= 4 then
					QuestSystem.refreshBoard(session, session.rng)
				end
				changed = true
			end
		end

		-- Hero recovery timers.
		local recovered = HeroSystem.tickStates(data)
		if #recovered > 0 then
			for _, heroId in ipairs(recovered) do
				local hero = data.heroes[heroId]
				Remotes[RemoteNames.Notify]:FireClient(player, { kind = "info", text = hero.name .. " is back on their feet." })
			end
			changed = true
		end

		-- Queue seat expiry + refills.
		if QueueSystem.expireSeats(data) > 0 then
			changed = true
		end
		if #QueueSystem.fillSeats(data, session.rng) > 0 then
			changed = true
		end

		-- Board refresh timer (only once the FTUE has released the board).
		if data.ftue.step >= 4 and now - (session.boardRefreshedAt or 0) >= Constants.BOARD_REFRESH_MIN * 60 then
			for id, posting in pairs(session.board) do
				if not posting.scripted then
					session.board[id] = nil
				end
			end
			QuestSystem.refreshBoard(session, session.rng)
			changed = true
		end

		-- Floor patrons.
		local spawned, despawned = FloorSystem.tick(session, session.rng, currentAct(data))
		if #spawned > 0 or #despawned > 0 then
			rebuildNpcs(session)
		end

		-- Autosave (spec §3: save on meaningful change + 60s autosave).
		if now - session.lastSaveAt >= Constants.AUTOSAVE_SEC then
			session.lastSaveAt = now
			data.lastSeenAt = now
			task.spawn(saveData, player, false)
		end

		if changed then
			syncState(session)
			rebuildNpcs(session)
		end
	end
end)
