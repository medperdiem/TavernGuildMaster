--!strict
-- SharedTypes.luau — type annotations shared by server and client.
-- Documentation-grade types; systems pass plain tables shaped like these.

export type Prefs = {
	gold: number,
	honor: number,
	gear: number,
	honesty: number,
}

export type HeroSave = {
	archetype: string,
	name: string,
	tier: number,
	loyalty: number,
	state: string, -- "idle" | "questing" | "injured" | "resting"
	injuryEndsAt: number,
	quirkId: string,
	quirkKnown: boolean,
	prefs: Prefs,
	flags: { [string]: boolean | string },
	chainProgress: number,
	gearBonus: number,
}

export type Prospect = {
	archetype: string,
	prefs: Prefs,
	quirkId: string,
	expiresAt: number,
	revealedPref: string,
}

export type Posting = {
	id: string,
	verb: string,
	subject: string,
	antagonist: string,
	location: string,
	twists: { string },
	difficulty: number,
	rewardMin: number,
	rewardMax: number,
	hint: string?,
	text: string,
	giver: string,
	scripted: boolean?,
}

export type ActiveQuest = {
	id: string,
	spec: Posting,
	heroIds: { string },
	startedAt: number,
	endsAt: number,
	ravenPlan: { number },
	firedRavens: number,
	modifiers: { [string]: number },
	choices: { string },
}

export type PlayerData = {
	version: number,
	gold: number,
	reputation: {
		score: number,
		record: { contractsBroken: number, poachesDefended: number, questsAbandoned: number },
	},
	heroes: { [string]: HeroSave },
	queue: { [string]: Prospect },
	activeQuests: { [string]: ActiveQuest },
	tavern: { decor: { string }, upgrades: { [string]: number } },
	lastSeenAt: number,
	ftue: { step: number },
	repQuestsToday: number,
	repQuestsDay: number,
}

return nil
