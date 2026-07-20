--!nonstrict
-- FTUESystem.luau — the scripted hour one as a step counter (spec §7 step 8 ⚖).
-- "When ftue.step == N, spawn X with dialogue key Y." Crude, fully sufficient.
--
-- Steps:
--   0  fresh save → uncle's letter plays
--   1  scripted Bram waits at the bar (signs free)
--   2  scripted easy Thornwood posting up — returns as a guaranteed Setback
--   3  the first real decision: Cleric vs Rogue, gold for only one
--   4+ released: normal queue flow + the cliffhanger overreach posting

local HttpService = game:GetService("HttpService")

local Data = script.Parent.Parent:WaitForChild("Data")
local Dialogue = require(Data:WaitForChild("Dialogue"))
local QuestTables = require(Data:WaitForChild("QuestTables"))
local Constants = require(Data:WaitForChild("Constants"))

local Systems = script.Parent
local QueueSystem = require(Systems:WaitForChild("QueueSystem"))

local FTUESystem = {}

local function scriptedPosting(overrides)
	local thornwood = QuestTables.Regions.thornwood
	local posting = {
		id = HttpService:GenerateGUID(false),
		region = "thornwood",
		verb = "HUNT",
		subject = "wolves",
		antagonist = thornwood.antagonists[1], -- wolves [1]
		location = "the old coach road",
		twists = {},
		difficulty = 2,
		hint = thornwood.hints.MIGHT,
		giver = "the farmers' collective",
		scripted = true,
	}
	for key, value in pairs(overrides) do
		posting[key] = value
	end
	posting.text = posting.text
		or string.format(QuestTables.Verbs[posting.verb].phrase, posting.antagonist.name, posting.location) .. "."
	posting.rewardMin = posting.rewardMin or math.floor(Constants.QUEST_REWARD_BASE * posting.difficulty * 0.8)
	posting.rewardMax = posting.rewardMax or math.floor(Constants.QUEST_REWARD_BASE * posting.difficulty * 1.5)
	return posting
end

-- Called on join. Returns an FtueEvent payload for the client, or nil when done.
function FTUESystem.onJoin(session)
	local step = session.data.ftue.step
	if step == 0 then
		return { kind = "letter", text = Dialogue.UnclesLetter }
	elseif step == 1 then
		FTUESystem.placeBram(session)
	elseif step == 2 then
		FTUESystem.postScriptedQuest(session)
	elseif step == 3 then
		FTUESystem.placeFirstChoice(session)
	end
	return nil
end

-- Client acknowledged the letter → Bram appears (design doc §11: first hero < 5 min).
function FTUESystem.acknowledge(session)
	local ftue = session.data.ftue
	if ftue.step == 0 then
		ftue.step = 1
		FTUESystem.placeBram(session)
		return true
	end
	return false
end

function FTUESystem.placeBram(session)
	if not session.data.queue.seat1 then
		QueueSystem.placeScripted(session.data, "seat1", "farmhand", session.rng)
	end
end

-- First hero signed → the scripted first quest goes up (guaranteed drama: Setback).
function FTUESystem.onHeroSigned(session, archetype)
	local ftue = session.data.ftue
	if ftue.step == 1 and archetype == "farmhand" then
		ftue.step = 2
		FTUESystem.postScriptedQuest(session)
	elseif ftue.step == 3 and (archetype == "cleric" or archetype == "rogue") then
		ftue.step = 4
		FTUESystem.postCliffhanger(session)
	end
end

function FTUESystem.postScriptedQuest(session)
	session.board = session.board or {}
	for _, posting in pairs(session.board) do
		if posting.scripted then
			return
		end
	end
	for _, quest in pairs(session.data.activeQuests) do
		if quest.spec.scripted then
			return -- the wolves job is already in flight
		end
	end
	local posting = scriptedPosting({
		forcedOutcome = "Setback", -- he limps home; "Worth it, boss." does the onboarding
		scriptedDuration = 90, -- short: the loop must prove itself in one sitting
	})
	session.board[posting.id] = posting
end

-- Scripted quest resolved → the two-prospect choice (Cleric vs Rogue, gold for one).
function FTUESystem.onQuestResolved(session, report)
	local ftue = session.data.ftue
	if ftue.step == 2 and report.outcome == "Setback" then
		ftue.step = 3
		FTUESystem.placeFirstChoice(session)
	end
end

function FTUESystem.placeFirstChoice(session)
	local data = session.data
	local hasArchetype = {}
	for _, hero in pairs(data.heroes) do
		hasArchetype[hero.archetype] = true
	end
	if not data.queue.seat1 and not hasArchetype.cleric then
		QueueSystem.placeScripted(data, "seat1", "cleric", session.rng)
	end
	if not data.queue.seat2 and not hasArchetype.rogue then
		QueueSystem.placeScripted(data, "seat2", "rogue", session.rng)
	end
end

-- The soft cliffhanger: a sealed courier posting one band above safe (design doc §11).
function FTUESystem.postCliffhanger(session)
	local posting = scriptedPosting({
		verb = "RESCUE",
		subject = "a merchant's daughter",
		antagonist = QuestTables.Regions.thornwood.antagonists[7], -- Redcap [3]
		location = "the burned watchtower",
		difficulty = 4,
		giver = "an anonymous red-wax letter",
		text = "SEALED: Bring back a merchant's daughter from the burned watchtower — the seal is unfamiliar, the pay is not.",
	})
	session.board = session.board or {}
	session.board[posting.id] = posting
end

return FTUESystem
