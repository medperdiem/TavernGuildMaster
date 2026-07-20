--!nonstrict
-- Main.client.luau — remote wiring and screen orchestration.
-- Client renders and requests; server owns all state (spec §2).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RemoteNames"))
local Screens = require(script.Parent:WaitForChild("UI"):WaitForChild("Screens"))
local Theme = require(script.Parent:WaitForChild("UI"):WaitForChild("Theme"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotesFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
local function remote(name)
	return remotesFolder:WaitForChild(name)
end

local screens
screens = Screens.create(playerGui, {
	onInterviewChoice = function(index)
		remote(RemoteNames.InterviewChoice):FireServer(index)
	end,
	onInterviewAsk = function(which)
		remote(RemoteNames.InterviewAsk):FireServer(which)
	end,
	onInterviewDecide = function(decision)
		remote(RemoteNames.InterviewDecide):FireServer(decision)
	end,
	onLaunch = function(postingId, heroIds)
		remote(RemoteNames.LaunchQuest):FireServer(postingId, heroIds)
	end,
	onRequestOdds = function(postingId, heroIds)
		return remote(RemoteNames.RequestOdds):InvokeServer(postingId, heroIds)
	end,
	onRavenChoice = function(questId, optionIndex)
		remote(RemoteNames.RavenChoice):FireServer(questId, optionIndex)
	end,
	onHeal = function(heroId)
		remote(RemoteNames.HealHero):FireServer(heroId)
	end,
	onFtueAdvance = function()
		remote(RemoteNames.FtueAdvance):FireServer()
	end,
})

-- ============================================================
-- Server → client
-- ============================================================
remote(RemoteNames.StateSync).OnClientEvent:Connect(function(state)
	screens.state.heroes = state.heroes
	screens.state.board = state.board
	screens.state.quests = state.quests
	screens:setGold(state.gold)
	screens:setQuests(state.quests)
end)

remote(RemoteNames.InterviewUpdate).OnClientEvent:Connect(function(update)
	screens:interviewUpdate(update)
end)

remote(RemoteNames.RavenEvent).OnClientEvent:Connect(function(raven)
	screens:showRaven(raven)
end)

remote(RemoteNames.QuestReport).OnClientEvent:Connect(function(report)
	screens:showReport(report)
end)

remote(RemoteNames.WelcomeBack).OnClientEvent:Connect(function(haul)
	screens:showWelcomeBack(haul)
end)

remote(RemoteNames.FtueEvent).OnClientEvent:Connect(function(event)
	if event.kind == "letter" then
		screens:showLetter(event.text)
	end
end)

remote(RemoteNames.Notify).OnClientEvent:Connect(function(notify)
	local prefix = ""
	local color
	if notify.kind == "fireside" or notify.kind == "quirk" then
		prefix = (notify.name or "") .. ": "
		color = Theme.Parchment
	elseif notify.kind == "serve" then
		prefix = "+" .. tostring(notify.gold or 0) .. "g · "
		color = Theme.Warn
	elseif notify.kind == "eavesdrop" then
		prefix = "(overheard) "
		color = Theme.TextDim
	elseif notify.kind == "raven" then
		color = Theme.Ember
	elseif notify.kind == "heal" then
		prefix = (notify.name or "") .. ": "
		color = Theme.Good
	end
	screens:toast(prefix .. (notify.text or ""), color)
end)

-- ============================================================
-- Job board opens from its ProximityPrompt on the 3D board.
-- ============================================================
task.spawn(function()
	local tavern = Workspace:WaitForChild("Tavern")
	local board = tavern:WaitForChild("JobBoard")
	local boardPart = board:WaitForChild("Board")
	local prompt = boardPart:WaitForChild("BoardPrompt")
	prompt.Triggered:Connect(function()
		screens:showBoard(screens.state.board or {})
	end)
end)

-- Quest tracker countdowns tick locally between syncs.
task.spawn(function()
	while true do
		task.wait(1)
		if screens.state.quests and #screens.state.quests > 0 then
			screens:setQuests(screens.state.quests)
		end
	end
end)
