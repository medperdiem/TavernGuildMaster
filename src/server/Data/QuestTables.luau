--!nonstrict
-- QuestTables.luau — procedural quest content (quest tables doc → data).
-- Slice 1 ships THORNWOOD only; the schema already carries regions 2–6 (Slice 2+).
-- A quest = VERB + SUBJECT + ANTAGONIST + LOCATION + 0–2 TWISTS, filtered by region.
-- Difficulty = region tier + antagonist rank + (1 per twist).

local QuestTables = {}

-- ============================================================
-- VERBS (6). phrase slots: {subject} {location} {antagonist}
-- ============================================================
QuestTables.Verbs = {
	RESCUE = {
		phrase = "Bring back %s from %s",
		ravens = { "risk", "reveal", "character" },
	},
	ESCORT = {
		phrase = "See %s safely through %s",
		ravens = { "risk", "character" },
	},
	HUNT = {
		phrase = "Put an end to %s plaguing %s",
		antagonistLead = true, -- subject slot takes the antagonist name
		ravens = { "risk", "character" },
	},
	RETRIEVE = {
		phrase = "Recover %s from %s",
		ravens = { "risk", "reveal" },
	},
	INVESTIGATE = {
		phrase = "Learn the truth of %s at %s",
		ravens = { "reveal", "character" },
	},
	NEGOTIATE = {
		phrase = "Settle terms over %s with %s",
		antagonistSecond = true, -- second slot takes the antagonist name
		ravens = { "reveal", "character" },
	},
}
QuestTables.VerbOrder = { "RESCUE", "ESCORT", "HUNT", "RETRIEVE", "INVESTIGATE", "NEGOTIATE" }

-- ============================================================
-- REGIONS (Slice 1: Thornwood live; others locked)
-- Antagonists carry the beat-resolver fields (spec §4):
--   rank · primaryAxis · secondaryAxis · tags
-- ============================================================
QuestTables.Regions = {
	thornwood = {
		name = "Thornwood",
		tier = 1,
		unlocked = true,
		twistCount = { 0, 1 }, -- rolls 0–1 twists (teaching region)
		subjects = {
			"a merchant's daughter",
			"a lost hunting party",
			"the miller's strongbox",
			"a stolen mule train",
			"the harvest tithe",
			"a runaway apprentice",
			"the old ranger's maps",
			"a beekeeper's prize hives",
			"a wandering peddler",
			"the village's festival ale",
		},
		antagonists = {
			{ name = "wolves", rank = 1, primaryAxis = "MIGHT", secondaryAxis = "GUILE", tags = { "beast" } },
			{ name = "a petty bandit gang", rank = 1, primaryAxis = "MIGHT", secondaryAxis = "PRESENCE", tags = { "bandit" } },
			{ name = "a black bear", rank = 1, primaryAxis = "MIGHT", secondaryAxis = "WARDING", tags = { "beast", "fear" } },
			{ name = "the Bramble Boys", rank = 2, primaryAxis = "PRESENCE", secondaryAxis = "MIGHT", tags = { "bandit", "comic" } },
			{ name = "a poacher ring", rank = 2, primaryAxis = "GUILE", secondaryAxis = "MIGHT", tags = { "bandit" } },
			{ name = "a swindling 'toll collector'", rank = 2, primaryAxis = "PRESENCE", secondaryAxis = "GUILE", tags = { "deceiver" } },
			{ name = "the bandit chief Redcap", rank = 3, primaryAxis = "MIGHT", secondaryAxis = "GUILE", tags = { "bandit", "boss" } },
		},
		locations = {
			"the old coach road",
			"Wolfhollow",
			"the mill crossing",
			"the burned watchtower",
			"Thornwood deeps",
			"the shepherd's high meadow",
		},
		hints = {
			MIGHT = "they respect a show of force",
			GUILE = "fast legs beat strong arms here",
			PRESENCE = "a friendly face opens the toll gate",
			WARDING = "steady nerves and a warm blessing help",
		},
	},
	-- Slice 2+: crypts, gildport, ironvein, stormreach, marches (tables in quest doc §2).
}

-- ============================================================
-- TWISTS (Thornwood-legal subset of quest doc §3).
-- leak: "H" may leak a hint on the posting · "R" surfaces only via reveal raven.
-- axis: which supply axis the twist's COMPLICATION beat tests.
-- demandMod: added to demand on its beat.
-- ============================================================
QuestTables.Twists = {
	collapsing = {
		name = "Collapsing ground",
		leak = "H",
		axis = "GUILE",
		demandMod = 1,
		hint = "the ground is unsteady — speed beats strength",
	},
	double_bounty = {
		name = "Double bounty",
		leak = "R",
		axis = "MIGHT",
		demandMod = 1,
		revealRaven = "double_bounty",
	},
	rival_crew = {
		name = "Rival crew on-site",
		leak = "H",
		axis = "GUILE",
		demandMod = 1,
		hint = "another crew has eyes on the same job",
	},
	the_witness = {
		name = "The witness",
		leak = "R",
		axis = "PRESENCE",
		demandMod = 0,
		revealRaven = "the_witness",
	},
	night_work = {
		name = "Night work",
		leak = "H",
		axis = "GUILE",
		demandMod = 1,
		hint = "the job runs past dark",
	},
	weeping_client = {
		name = "Weeping client",
		leak = "H",
		axis = "PRESENCE",
		demandMod = 0,
		hint = "the client is... invested. Deeply. Tearfully",
	},
	target_lies = {
		name = "The target lies",
		leak = "R",
		axis = "PRESENCE",
		demandMod = 1,
		revealRaven = "target_lies",
	},
	its_a_trap = {
		name = "It's a trap",
		leak = "R",
		axis = "WARDING",
		demandMod = 1,
		revealRaven = "its_a_trap",
	},
	festival_traffic = {
		name = "Festival traffic",
		leak = "H",
		axis = "PRESENCE",
		demandMod = 0,
		hint = "the whole valley's on the roads — and watching",
	},
	cursed_ground = {
		name = "Cursed ground",
		leak = "H",
		axis = "WARDING",
		demandMod = 1,
		hint = "the ground there is old and unquiet — blessed hands help",
	},
	bandits_are_farmers = {
		name = "The 'bandits' are farmers",
		leak = "R",
		axis = "PRESENCE",
		demandMod = 0,
		revealRaven = "bandits_are_farmers",
	},
}
QuestTables.ThornwoodTwists = {
	"collapsing",
	"double_bounty",
	"rival_crew",
	"the_witness",
	"night_work",
	"weeping_client",
	"target_lies",
	"its_a_trap",
	"festival_traffic",
	"bandits_are_farmers",
	"cursed_ground",
}

-- ============================================================
-- RISK-FORK RAVENS per verb (quest doc §4.1).
-- Option effects understood by QuestSystem:
--   widen (d6→d8 both ways) · safe (demand −1 on next beat) · slow (adds duration)
--   fast (cuts duration) · rep / gold / injury_risk side effects
-- auto = option index taken on expiry.
-- ============================================================
QuestTables.RiskForks = {
	RESCUE = {
		{
			text = "The guards rotate at the hour. %s can rush now — loud, fast — or wait for the gap. Word?",
			options = {
				{ text = "Rush.", effects = { "fast", "widen" } },
				{ text = "Wait for the gap.", effects = { "slow", "safe" } },
			},
			auto = 2,
			autoText = "No word. %s waited for the gap.",
		},
		{
			text = "%s isn't alone — two other captives beg to come. More to carry, more to feed, more to save.",
			options = {
				{ text = "Take them all.", effects = { "rep_up", "slow", "risk_up" } },
				{ text = "Contract only.", effects = {} },
			},
			auto = 2,
		},
		{
			text = "The back way is flooded to the waist. Shortcut through cold water, or the long dry road past the watch?",
			options = {
				{ text = "The water.", effects = { "fast", "injury_risk" } },
				{ text = "The road.", effects = { "slow" } },
			},
			auto = 2,
		},
	},
	ESCORT = {
		{
			text = "The pass ahead is faster; the valley road is safer. %s says they're 'not in a hurry.' They are lying — check the contract date.",
			options = {
				{ text = "The pass.", effects = { "fast", "risk_up" } },
				{ text = "The valley road.", effects = { "slow", "safe" } },
			},
			auto = 2,
		},
		{
			text = "Push through the night to arrive early, or camp? %s notes the party's tired.",
			options = {
				{ text = "Push through.", effects = { "fast", "fatigue" } },
				{ text = "Camp.", effects = {} },
			},
			auto = 2,
		},
		{
			text = "A second caravan begs to join yours for protection. Bigger target, bigger thanks.",
			options = {
				{ text = "Accept them.", effects = { "rep_up", "gold_up", "demand_up" } },
				{ text = "Decline.", effects = {} },
			},
			auto = 2,
		},
	},
	HUNT = {
		{
			text = "Tracks split. The old sire went left — bigger bounty, worse odds. The young ones went right.",
			options = {
				{ text = "The sire.", effects = { "widen", "gold_up" } },
				{ text = "The young ones.", effects = {} },
			},
			auto = 2,
		},
		{
			text = "The lair has a back entrance. Smoke them out toward the party (clean, slow) or go in (fast, dark, personal)?",
			options = {
				{ text = "Smoke them out.", effects = { "slow", "safe" } },
				{ text = "Go in.", effects = { "fast", "injury_risk" } },
			},
			auto = 1,
		},
		{
			text = "The beast is denned with cubs. The contract says 'end the threat.' %s awaits interpretation.",
			options = {
				{ text = "Full clearance.", effects = { "gold_up", "rep_down" } },
				{ text = "Drive them off.", effects = { "gold_down", "rep_up" } },
			},
			auto = 2,
		},
	},
	RETRIEVE = {
		{
			text = "The party found a side way into the vault. Off the plan entirely.",
			options = {
				{ text = "The side way.", effects = { "widen" } },
				{ text = "Stick to the plan.", effects = {} },
			},
			auto = 2,
		},
		{
			text = "The object's twin sits beside it. Taking both isn't stealing if it's already stealing, argues the greediest member.",
			options = {
				{ text = "Take both.", effects = { "gold_up", "honesty_ding" } },
				{ text = "Take one.", effects = {} },
			},
			auto = 2,
		},
		{
			text = "Alarm tripped — not by ours. Someone else is robbing the place TONIGHT. Race them, or let them draw the guards?",
			options = {
				{ text = "Race them.", effects = { "widen", "fast" } },
				{ text = "Let them draw the guards.", effects = { "slow", "safe", "gold_down" } },
			},
			auto = 2,
		},
	},
	INVESTIGATE = {
		{
			text = "Two witnesses, one hour. The frightened maid knows more; the smug clerk lies better. Who first?",
			options = {
				{ text = "The maid.", effects = { "presence_path" } },
				{ text = "The clerk.", effects = { "guile_path" } },
			},
			auto = 1,
		},
		{
			text = "The truth is in the cellar ledger — behind a lock. Pick it (quiet, illegal) or petition for it (loud, legal, slow)?",
			options = {
				{ text = "Pick the lock.", effects = { "fast", "honesty_ding" } },
				{ text = "Petition.", effects = { "slow", "rep_up" } },
			},
			auto = 2,
		},
	},
	NEGOTIATE = {
		{
			text = "%s offers to settle early — at two-thirds terms. The full deal needs one more day at the table.",
			options = {
				{ text = "Take it.", effects = { "fast", "gold_down" } },
				{ text = "Hold out.", effects = { "slow", "gold_up", "risk_up" } },
			},
			auto = 1,
		},
		{
			text = "Their negotiator is drunk and friendly. Press the advantage now, or adjourn like honorable folk?",
			options = {
				{ text = "Press.", effects = { "gold_up", "honesty_ding" } },
				{ text = "Adjourn.", effects = { "rep_up" } },
			},
			auto = 2,
		},
	},
}

-- ============================================================
-- TWIST-REVEAL RAVENS (quest doc §4.2)
-- ============================================================
QuestTables.RevealRavens = {
	target_lies = {
		text = "The ransom note is a lie — the 'captive' is in on it. Spring the trap on THEM, or walk away with the fee and the secret?",
		options = {
			{ text = "Spring the trap.", effects = { "rep_up", "gold_up", "risk_up" } },
			{ text = "Walk away.", effects = { "safe" } },
		},
		auto = 2,
	},
	double_bounty = {
		text = "A second mark just surfaced — the contract's brother, twice the trouble, twice the purse. In or out?",
		options = {
			{ text = "In.", effects = { "widen", "gold_up" } },
			{ text = "Out.", effects = {} },
		},
		auto = 2,
	},
	the_witness = {
		text = "A chronicler has been following the party for two days, writing EVERYTHING. Play to the page, ignore, or pay for the pen?",
		options = {
			{ text = "Play to the page.", effects = { "rep_swing" } },
			{ text = "Ignore.", effects = {} },
			{ text = "Pay for the pen.", effects = { "gold_down", "honesty_ding" } },
		},
		auto = 2,
	},
	its_a_trap = {
		text = "It's a trap — the posting was bait and the door just barred. Fight through, or find the poster's real game first?",
		options = {
			{ text = "Fight through.", effects = { "risk_up" } },
			{ text = "Find the real game.", effects = { "slow", "guile_path" } },
		},
		auto = 1,
	},
	bandits_are_farmers = {
		text = "They're not bandits. They're farmers with borrowed swords and empty larders. The contract says clear the road.",
		options = {
			{ text = "Fight.", effects = { "fast", "rep_down" } },
			{ text = "Negotiate.", effects = { "slow", "rep_up" } },
			{ text = "Pay them yourself.", effects = { "gold_down", "rep_up" } },
		},
		auto = 2,
	},
}

-- ============================================================
-- QUEST-GIVER FLAVOR SLOTS (quest doc §5)
-- ============================================================
QuestTables.QuestGivers = {
	"the farmers' collective",
	"a nervous clerk with a seal he clearly borrowed",
	"an anonymous red-wax letter",
	"a child with exact coins and no explanation",
	"the town council, 4–3 vote attached",
	"a rival guild (swallow your pride, take their gold)",
}

return QuestTables
