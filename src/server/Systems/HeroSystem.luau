--!nonstrict
-- HeroSystem.luau — roster, loyalty, injuries, wages, party supply (spec §2, §4).
-- Stateless function library over PlayerData tables. GameServer owns the session.

local HttpService = game:GetService("HttpService")

local Data = script.Parent.Parent:WaitForChild("Data")
local Heroes = require(Data:WaitForChild("Heroes"))
local Dialogue = require(Data:WaitForChild("Dialogue"))
local Constants = require(Data:WaitForChild("Constants"))

local HeroSystem = {}

local function rollBand(band, rng)
	return rng:NextInteger(band[1], band[2])
end

-- Roll a fresh prospect for the queue (prefs rolled in archetype band, quirk from pool).
function HeroSystem.rollProspect(archetype, rng)
	local def = Heroes.get(archetype)
	assert(def, "unknown archetype " .. tostring(archetype))
	local prefs = {}
	for stat, band in pairs(def.prefBands) do
		prefs[stat] = rollBand(band, rng)
	end
	-- One visible preference on sit-down (spec §6): the highest-rolled stat.
	local revealed, best = "gold", -1
	for stat, value in pairs(prefs) do
		if value > best then
			best, revealed = value, stat
		end
	end
	return {
		archetype = archetype,
		prefs = prefs,
		quirkId = def.quirkPool[rng:NextInteger(1, #def.quirkPool)],
		expiresAt = os.time() + Constants.QUEUE_SEAT_HOURS * 3600,
		revealedPref = revealed,
	}
end

-- Sign a prospect into the roster. suspicious = lied in the interview.
function HeroSystem.signHero(data, prospect, suspicious)
	local id = HttpService:GenerateGUID(false)
	data.heroes[id] = {
		archetype = prospect.archetype,
		name = Heroes.get(prospect.archetype).name,
		tier = 1,
		loyalty = suspicious and Constants.LOYALTY_START_SUSPICIOUS or Constants.LOYALTY_START,
		state = "idle",
		injuryEndsAt = 0,
		quirkId = prospect.quirkId,
		quirkKnown = false,
		prefs = prospect.prefs,
		flags = {},
		chainProgress = 0,
		gearBonus = 0,
	}
	return id
end

function HeroSystem.addLoyalty(hero, amount)
	hero.loyalty = math.clamp(hero.loyalty + amount, 0, Constants.LOYALTY_MAX)
end

-- Loyalty register band for dialogue selection (script doc conventions).
function HeroSystem.register(hero)
	if hero.loyalty >= Constants.LOYALTY_BAND_DEVOTED then
		return "devoted"
	elseif hero.loyalty >= Constants.LOYALTY_BAND_TRUSTED then
		return "trusted"
	end
	return "signed"
end

-- A fireside line for the hero's current register, honoring memory-hook variants.
function HeroSystem.firesideLine(hero, rng)
	local pack = Dialogue.forHero(hero.archetype)
	if not pack then
		return nil
	end
	local band = HeroSystem.register(hero)
	local registers = pack.registers or {}
	-- Memory-hook variants take priority when their flag is set (script doc §13.2).
	if band == "trusted" and hero.flags.told_truth and registers.trusted_told_truth then
		return registers.trusted_told_truth
	end
	if band == "devoted" and hero.flags.lied_interview and registers.devoted_lied then
		return registers.devoted_lied
	end
	if band == "devoted" and hero.flags.told_truth and registers.devoted_told_truth then
		return registers.devoted_told_truth
	end
	local pool = registers[band]
	if pool and #pool > 0 then
		return pool[rng:NextInteger(1, #pool)]
	end
	return nil
end

-- Party supply across the four axes (spec §4): tier + gearBonus per axis; injury/fatigue −1.
function HeroSystem.partySupply(data, heroIds)
	local supply = { MIGHT = 0, GUILE = 0, PRESENCE = 0, WARDING = 0 }
	for _, id in ipairs(heroIds) do
		local hero = data.heroes[id]
		if hero then
			local def = Heroes.get(hero.archetype)
			local contribution = hero.tier + (hero.gearBonus or 0)
			if hero.flags.fatigued then
				contribution = math.max(0, contribution - 1)
			end
			for _, axis in ipairs(def.axes) do
				supply[axis] = supply[axis] + contribution
			end
		end
	end
	return supply
end

-- Average party level for the overreach gap multiplier.
function HeroSystem.partyLevel(data, heroIds)
	local total, count = 0, 0
	for _, id in ipairs(heroIds) do
		local hero = data.heroes[id]
		if hero then
			total += hero.tier
			count += 1
		end
	end
	return count > 0 and (total / count) or 0
end

-- Injure a hero (Setback/Disaster roll). Returns recovery end time.
function HeroSystem.injure(data, heroId, rng)
	local hero = data.heroes[heroId]
	if not hero then
		return nil
	end
	hero.state = "injured"
	hero.injuryEndsAt = os.time() + rng:NextInteger(Constants.INJURY_RECOVERY_SEC[1], Constants.INJURY_RECOVERY_SEC[2])
	-- Maren's quirk: loyalty rises when guildmates return injured (design doc §2.3).
	for _, other in pairs(data.heroes) do
		if other.quirkId == "mends_the_hurt" and other ~= hero then
			HeroSystem.addLoyalty(other, Constants.LOYALTY_QUIRK_TICK)
			other.quirkKnown = true
		end
	end
	return hero.injuryEndsAt
end

-- Pay gold to clear an injury immediately-ish (cost, not time — design doc §8c).
function HeroSystem.heal(data, heroId)
	local hero = data.heroes[heroId]
	if not hero or hero.state ~= "injured" then
		return false, "not injured"
	end
	if data.gold < Constants.HEAL_COST_PER_INJURY then
		return false, "not enough gold"
	end
	data.gold -= Constants.HEAL_COST_PER_INJURY
	hero.state = "resting"
	hero.injuryEndsAt = math.min(hero.injuryEndsAt, os.time() + 60)
	HeroSystem.addLoyalty(hero, Constants.LOYALTY_HEALED)
	return true
end

-- Tick timed states (injury recovery). Returns list of heroIds that recovered.
function HeroSystem.tickStates(data)
	local recovered = {}
	local now = os.time()
	for id, hero in pairs(data.heroes) do
		if (hero.state == "injured" or hero.state == "resting") and hero.injuryEndsAt > 0 and now >= hero.injuryEndsAt then
			hero.state = "idle"
			hero.injuryEndsAt = 0
			table.insert(recovered, id)
		end
	end
	return recovered
end

-- Session wage bill (accrues silently in Slice 1 — spec §10).
function HeroSystem.wageBill(data, regionTier)
	local bill = 0
	for _, hero in pairs(data.heroes) do
		bill += Constants.WAGE_PER_HERO_TIER_PER_SESSION * hero.tier
	end
	return math.floor(bill * (1 + Constants.WAGE_REGION_INFLATION * (regionTier or 1)))
end

-- Quirk hook: stew served on the floor (Bram/Alduin category "kitchen").
function HeroSystem.onStewServed(data)
	local fired = {}
	for id, hero in pairs(data.heroes) do
		local quirk = Heroes.Quirks[hero.quirkId]
		if quirk and quirk.category == "kitchen" and hero.state ~= "questing" then
			HeroSystem.addLoyalty(hero, Constants.LOYALTY_QUIRK_TICK)
			if not hero.quirkKnown then
				hero.quirkKnown = true
				table.insert(fired, id)
			end
		end
	end
	return fired
end

return HeroSystem
