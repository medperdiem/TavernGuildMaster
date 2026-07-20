--!nonstrict
-- EconomySystem.luau — gold, floor income, offline accrual (spec §2, design doc §8).
-- Wages accrue silently in Slice 1 (spec §10 ⚖): the drain is real, the UI is Slice 2.

local Data = script.Parent.Parent:WaitForChild("Data")
local Constants = require(Data:WaitForChild("Constants"))

local Systems = script.Parent
local HeroSystem = require(Systems:WaitForChild("HeroSystem"))

local EconomySystem = {}

-- Serve task payout.
function EconomySystem.paidServe(data)
	data.gold += Constants.FLOOR_INCOME_PER_SERVE
	return Constants.FLOOR_INCOME_PER_SERVE
end

-- Offline accrual: reduced rate, capped (design doc §8). Anchored on lastSeenAt.
function EconomySystem.offlineAccrual(data)
	if data.lastSeenAt <= 0 then
		return 0, 0
	end
	local awaySec = math.max(0, os.time() - data.lastSeenAt)
	local cappedHours = math.min(awaySec / 3600, Constants.OFFLINE_CAP_HOURS)
	local gold = math.floor(cappedHours * Constants.OFFLINE_GOLD_PER_HOUR * Constants.OFFLINE_RATE)
	data.gold += gold
	return gold, cappedHours
end

-- Session wage tick — charged once per play session on join (silent in S1).
function EconomySystem.chargeWages(data)
	local bill = HeroSystem.wageBill(data, 1)
	local paid = math.min(bill, data.gold)
	data.gold -= paid
	return paid
end

-- Build the welcome-back haul payload (spec §5 screen 7).
function EconomySystem.welcomeBackSummary(_data, offlineGold, questReports, arrivals, wagesPaid)
	local questLines = {}
	for _, report in ipairs(questReports) do
		table.insert(questLines, string.format("%s — %s (+%dg)", report.posting, report.outcome, report.gold))
	end
	return {
		gold = offlineGold,
		questLines = questLines,
		newProspects = arrivals,
		wagesPaid = wagesPaid, -- carried in the payload, not surfaced by S1 UI
		-- Doubler button slot exists but is DISABLED in Slice 1 — no store yet (spec §5).
		doublerEnabled = false,
	}
end

return EconomySystem
