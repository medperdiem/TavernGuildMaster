--!nonstrict
-- RemoteNames.luau — the single source of truth for RemoteEvent/Function names.
-- Server creates them under ReplicatedStorage.Remotes at boot; client waits on them.

return {
	Folder = "Remotes",

	-- Server → client
	StateSync = "StateSync", -- full player-state snapshot (gold, heroes, queue, board, quests, ftue)
	RavenEvent = "RavenEvent", -- a raven decision popup
	QuestReport = "QuestReport", -- beat-by-beat return report
	WelcomeBack = "WelcomeBack", -- offline haul summary
	InterviewUpdate = "InterviewUpdate", -- next interview node / result
	FloorEvent = "FloorEvent", -- patron spawn/despawn/order/whisper updates
	Notify = "Notify", -- toast lines (quirk fires, wages, register barks)
	FtueEvent = "FtueEvent", -- scripted hour-one beats (uncle's letter etc.)

	-- Client → server (all validated server-side)
	StartInterview = "StartInterview", -- (seatId)
	InterviewChoice = "InterviewChoice", -- (choiceIndex)
	InterviewAsk = "InterviewAsk", -- ("want"|"worked"|"know")
	InterviewDecide = "InterviewDecide", -- ("sign"|"wait")
	LaunchQuest = "LaunchQuest", -- (postingId, {heroIds})
	RavenChoice = "RavenChoice", -- (questId, optionIndex)
	ServePatron = "ServePatron", -- (patronId)
	Eavesdrop = "Eavesdrop", -- (patronId)
	HealHero = "HealHero", -- (heroId)
	TalkToHero = "TalkToHero", -- (heroId) → fireside register line
	FtueAdvance = "FtueAdvance", -- client acknowledges a scripted beat
	RequestOdds = "RequestOdds", -- RemoteFunction: (postingId, {heroIds}) → odds band
}
