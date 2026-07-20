--!nonstrict
-- Constants.luau — EVERY tunable number in one file (Slice 1 spec §6).
-- Values are sim-validated first passes (economy_sim.py v6); re-tune here, nowhere else.

local Constants = {
	-- Economy
	FLOOR_INCOME_PER_SERVE = 3,
	QUEST_REWARD_BASE = 22, -- × difficulty × gapMult
	OVERREACH_GAP_MULT = 1.5, -- per band above party level
	OFFLINE_RATE = 0.4,
	OFFLINE_CAP_HOURS = 10,
	OFFLINE_GOLD_PER_HOUR = 18, -- base accrual before OFFLINE_RATE
	WAGE_PER_HERO_TIER_PER_SESSION = 8,
	WAGE_REGION_INFLATION = 0.25, -- ×(1 + 0.25 × regionTier)
	HEAL_COST_PER_INJURY = 35,
	GEAR_REPAIR_COST = 25,
	RECRUIT_COST = { common = 75, uncommon = 300, rare = 1100, legendary = 4000 },
	REP_QUESTS_PER_DAY = 3,
	REP_QUEST_BOND_PER_DIFF = 24, -- accrues silently in S1 (rep UI is S2)
	STARTING_GOLD = 120,

	-- Pacing
	QUEST_DURATION_SEC = { 4 * 60, 12 * 60 }, -- 4–12 real minutes in Slice 1
	RAVEN_AT_FRACTIONS = { 0.33, 0.66 }, -- fire points along quest duration
	RAVEN_EXPIRY_SEC = 90,
	QUEUE_SEAT_HOURS = 36,
	BOARD_REFRESH_MIN = 20,
	BOARD_POSTING_COUNT = 3,
	QUEUE_SEATS = 2,
	QUEUE_ROLL_MIN = 8, -- minutes between prospect arrival checks
	PARTY_SIZE_MAX = 3,
	AUTOSAVE_SEC = 60,

	-- Loyalty
	LOYALTY_PERSONAL_QUEST = 10,
	LOYALTY_QUIRK_TICK = 3,
	LOYALTY_LIE_PENALTY = 15,
	LOYALTY_MAX = 100,
	LOYALTY_QUEST_TRIUMPH = 6,
	LOYALTY_QUEST_SUCCESS = 3,
	LOYALTY_QUEST_DISASTER = -8,
	LOYALTY_HEALED = 4,
	LOYALTY_START = 20,
	LOYALTY_START_SUSPICIOUS = 8,
	LOYALTY_BAND_TRUSTED = 40, -- SIGNED below this
	LOYALTY_BAND_DEVOTED = 80,

	-- Beats / resolution (spec §4)
	BEAT_DIE = 6, -- d6; ravens can widen to d8
	INJURY_RECOVERY_SEC = { 6 * 60, 15 * 60 }, -- Slice-1-short, like quest timers
	INJURY_CHANCE_SETBACK = 0.75,
	INJURY_CHANCE_DISASTER = 1.0,

	-- Floor
	PATRON_MAX = 6,
	PATRON_SPAWN_SEC = { 25, 60 },
	PATRON_LINGER_SEC = { 60, 150 },
	EAVESDROP_CHANCE = 0.35, -- fraction of patrons that carry a whisper
	SERVE_TIMEOUT_SEC = 45,
}

return Constants
