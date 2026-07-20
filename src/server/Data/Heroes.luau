--!nonstrict
-- Heroes.luau — archetype data for the Slice 1 roster (design doc §2, spec §1).
-- Pure data. Quirk CONDITIONS live in HeroSystem; this file only names them.
-- Party supply axes (spec §4): MIGHT · GUILE · PRESENCE · WARDING.

local Heroes = {}

-- Each archetype:
--   name          fixed display name (no player naming in Slice 1)
--   rarity        keys RECRUIT_COST + interview depth
--   axes          1–2 supply axes the hero contributes (tier + gearBonus) to
--   prefBands     {min, max} roll band per preference at spawn
--   quirkPool     quirk ids rolled at spawn (Slice 1: one per hero)
--   tierNames     upgrade arc labels (chains beyond FTUE prompt are Slice 2)
--   signWeight    relative weight in the queue roll
Heroes.Archetypes = {
	farmhand = {
		name = "Bram",
		rarity = "common",
		axes = { "MIGHT" },
		prefBands = { gold = { 3, 4 }, honor = { 1, 2 }, gear = { 2, 3 }, honesty = { 2, 3 } },
		quirkPool = { "stew_lover" },
		tierNames = { "Farmhand Fighter", "Sword Fighter", "Militia Captain" },
		signWeight = 10,
	},
	minstrel = {
		name = "Perrin",
		rarity = "common",
		axes = { "PRESENCE" },
		prefBands = { gold = { 1, 2 }, honor = { 2, 3 }, gear = { 1, 2 }, honesty = { 3, 4 } },
		quirkPool = { "needs_stage" },
		tierNames = { "Busker", "Bard", "Songweaver" },
		signWeight = 8,
	},
	rogue = {
		name = "Vex",
		rarity = "common",
		axes = { "GUILE" },
		prefBands = { gold = { 3, 4 }, honor = { 1, 1 }, gear = { 3, 4 }, honesty = { 2, 3 } },
		quirkPool = { "hates_crowds" },
		tierNames = { "Pickpocket", "Burglar", "Shadow Agent" },
		signWeight = 8,
	},
	cleric = {
		name = "Sister Maren",
		rarity = "common",
		axes = { "WARDING", "PRESENCE" },
		prefBands = { gold = { 1, 1 }, honor = { 3, 4 }, gear = { 1, 2 }, honesty = { 3, 4 } },
		quirkPool = { "mends_the_hurt" },
		tierNames = { "Acolyte", "Priest", "High Cleric" },
		signWeight = 8,
	},
	barbarian = {
		name = "Grunwald",
		rarity = "uncommon",
		axes = { "MIGHT" },
		prefBands = { gold = { 2, 3 }, honor = { 1, 1 }, gear = { 4, 4 }, honesty = { 2, 3 } },
		quirkPool = { "flees_temptation" },
		tierNames = { "Nervous Barbarian", "Reluctant Barbarian", "Reckless Barbarian" },
		signWeight = 4,
	},
	gourmet_knight = {
		name = "Sir Alduin",
		rarity = "uncommon",
		axes = { "MIGHT", "PRESENCE" },
		prefBands = { gold = { 1, 2 }, honor = { 4, 4 }, gear = { 2, 3 }, honesty = { 3, 4 } },
		quirkPool = { "kitchen_devotee" },
		tierNames = { "Hungry Squire", "Feast Knight", "Paladin of Plenty" },
		signWeight = 4,
	},
}

-- Quirk metadata: category is what eavesdrop hints leak (never the quirk itself).
Heroes.Quirks = {
	stew_lover = { category = "kitchen", hint = "keeps glancing at the kitchen" },
	needs_stage = { category = "decor", hint = "hums at the empty corner where a stage could be" },
	hates_crowds = { category = "queue", hint = "counts the room every time the door opens" },
	mends_the_hurt = { category = "roster", hint = "watches the stairs whenever someone limps" },
	flees_temptation = { category = "pvp", hint = "sits with a clear view of every exit" },
	kitchen_devotee = { category = "kitchen", hint = "rated the bread. Out loud. Twice" },
}

-- Ordered roll table for the queue (rarity odds; rep-tier scaling arrives in Slice 2).
Heroes.QueueRollOrder = { "farmhand", "minstrel", "rogue", "cleric", "barbarian", "gourmet_knight" }

function Heroes.get(archetype)
	return Heroes.Archetypes[archetype]
end

return Heroes
