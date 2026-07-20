"""
Adventurer Tavern — Economy Testing Engine
===========================================
Discrete-session Monte Carlo simulation of the full game economy.
Every tunable lives in CONFIG. Change numbers, re-run, read the report.

Facets covered:
  Income:   floor serves, quest rewards (difficulty x overreach), offline accrual (capped),
            open-board bonus, region resources (non-gold, earn-only)
  Expenses: recruiting, wages (roster carrying cost), healing, gear repair,
            tavern upgrades, poach tokens, raid skims
  Disruptors: disasters (triple hit), timed-posting expiry (opportunity cost),
            weather volatility (Stormreach+), contract-break reputation damage
            (suppresses queue quality), open-board raids, seasonal resource shifts
  Convenience (counterfactual): infirmary, workshop, staff, roster slots, offline doubler
            -> measured as TIME saved, with a ceiling-parity check (must not raise ceiling)

Player archetypes: casual, grinder, gambler, whale (grinder+spend).
"""

import random
import statistics as stats
from dataclasses import dataclass, field
from copy import deepcopy

# ----------------------------------------------------------------------------
# CONFIG — every tunable number in the economy
# ----------------------------------------------------------------------------
CONFIG = {
    # --- session structure ---
    "SESSIONS": 60,                    # simulated play sessions (~1/day)
    "N_PLAYERS": 300,                  # monte carlo population per archetype

    # --- income ---
    "FLOOR_INCOME_PER_SERVE": 3,
    "SERVES_PER_ACTIVE_MIN": 0.5,      # serve tasks available per active minute
    "QUEST_REWARD_BASE": 22,           # x difficulty x gap multiplier
    "OVERREACH_GAP_MULT": 1.5,         # per band above party power
    "OFFLINE_RATE": 0.4,               # fraction of active income rate while away
    "OFFLINE_CAP_HOURS": 10,
    "OFFLINE_INCOME_PER_HOUR": 12,     # base offline gold/hour before rate/cap
    "OPEN_BOARD_BONUS": 1.6,           # offline rate multiplier when listed
    "OPEN_BOARD_RAID_CHANCE": 0.18,    # per offline period listed
    "OPEN_BOARD_RAID_SKIM": 0.35,      # fraction of accrued offline gold skimmed

    # --- expenses ---
    "RECRUIT_COST": {1: 75, 2: 300, 3: 1100, 4: 4000},   # by rarity (common..legendary)
    "WAGE_PER_TIER_PER_SESSION": 8,
    "HEAL_COST_PER_INJURY": 35,
    "HEAL_SESSIONS": 2,                # sessions a hero is out when injured
    "GEAR_REPAIR_COST": 25,            # per setback/disaster, per party
    "UPGRADE_COSTS": [120, 400, 1100, 2800, 7000],  # tavern upgrade ladder
    "UPGRADE_FLOOR_BONUS": 0.15,       # +15% floor & offline income per upgrade level

    # --- quests ---
    "QUESTS_PER_SESSION_MAX": 3,       # concurrent parties cap (roster permitting)
    "PARTY_SIZE": 3,
    "BASE_SUCCESS_CENTER": 0.62,       # prob of >=Success at gap 0
    "GAP_SUCCESS_PENALTY": 0.13,       # per band of overreach
    "TRIUMPH_SHARE": 0.30,             # of successful outcomes at gap 0 (+ per gap below)
    "DISASTER_SHARE": 0.35,            # of failed outcomes (rest are setbacks)
    "WEATHER_VOLATILITY": 0.10,        # extra +/- success swing in region >=5
    "TIMED_POSTING_CHANCE": 0.25,      # lucrative timed posting appears (region>=4)
    "TIMED_POSTING_BONUS": 2.0,        # reward mult if caught
    "TIMED_MISS_IF_GAP_DAYS": 2,       # missed if player session gap exceeds this

    # --- reputation & regions ---
    # v2 tune: rep scales with DIFFICULTY so overreach pays progression
    # (v1 flat rep made safe play strictly dominant — casual outpaced grinder)
    "REP_PER_SUCCESS_PER_DIFF": 1.5, "REP_PER_TRIUMPH_PER_DIFF": 2.5,
    "REP_QUESTS_PER_SESSION": 3,   # cap stays 3
    "REP_QUEST_BOND_PER_DIFF": 24,  # gold bond to register a rep contract (new sink; scarcity gates the 3rd fill)
    "REP_PER_DISASTER": -2, "REP_ABANDON": -1,
    "REP_CONTRACT_BREAK": -25,         # trust breaks fast
    "CONTRACT_BREAK_CHANCE": 0.02,     # per session for 'sloppy' behavior flag
    "QUEUE_SUPPRESS_SESSIONS": 8,      # sessions of degraded queue after a break
    "REGION_GATES": [0, 30, 80, 160, 280, 430],  # rep needed for region 1..6
    "REGION_DIFF_TIER": [1, 2, 3, 4, 5, 6],
    "RESOURCE_PER_SUCCESS": 1,         # region resources per success in-region

    # --- recruiting / roster ---
    "TARGET_ROSTER_BY_REGION": [3, 5, 7, 9, 11, 13],
    "RARITY_ODDS_BY_REPTIER": {        # rep tier -> odds of rarity 1..4 in queue
        0: [0.95, 0.05, 0.00, 0.00],
        1: [0.75, 0.22, 0.03, 0.00],
        2: [0.55, 0.33, 0.11, 0.01],
        3: [0.40, 0.38, 0.19, 0.03],
        4: [0.30, 0.40, 0.24, 0.06],
    },
    "REP_TIER_GATES": [0, 30, 120, 250, 400],
    "QUEUE_SUPPRESS_FACTOR": 0.5,      # rarity odds shift toward common when suppressed

    # --- convenience purchases (whale counterfactuals) ---
    "CONV_INFIRMARY_HEAL_SESSIONS": 2,     # v5: time-neutral again
    "CONV_HEAL_COST_MULT": 0.5,            # v3: it halves the COST instead
    "CONV_WORKSHOP_REPAIR_MULT": 0.5,
    "CONV_STAFF_FLOOR_MULT": 0.85,         # staff earn 85% of manual, but always-on
    "CONV_EXTRA_ROSTER": 0,   # v5: bench-only again
    "CONV_DOUBLER_THRESHOLD": 80,          # doubles offline haul when above this
    "SEASONAL_EVERY": 15,                  # sessions; one resource x2, another x0.5
}

RARITY_TIER_POWER = {1: 1, 2: 2, 3: 3, 4: 5}   # hero power contribution by rarity

# ----------------------------------------------------------------------------
# Archetypes
# ----------------------------------------------------------------------------
ARCHETYPES = {
    #            active_min, gap_days, risk_band, floor_diligence, sloppy, open_board, spends
    "casual":   dict(active=12, gap=2.5, risk=0,  floor=0.4, sloppy=False, board=False, spends=False),
    "grinder":  dict(active=30, gap=1.0, risk=1,  floor=0.9, sloppy=False, board=False, spends=False),
    "gambler":  dict(active=25, gap=1.0, risk=2,  floor=0.6, sloppy=True,  board=True,  spends=False),
    "whale":    dict(active=30, gap=1.0, risk=1,  floor=0.9, sloppy=False, board=False, spends=True),
}

# ----------------------------------------------------------------------------
# Model
# ----------------------------------------------------------------------------
@dataclass
class Hero:
    rarity: int
    injured_until: int = -1
    def power(self): return RARITY_TIER_POWER[self.rarity]

@dataclass
class Player:
    arch: dict
    cfg: dict
    gold: float = 60.0
    rep: float = 0.0
    resources: float = 0.0
    heroes: list = field(default_factory=lambda: [Hero(1)])
    upgrades: int = 0
    queue_suppressed_until: int = -1
    robux_spent_events: int = 0
    # telemetry
    log: dict = field(default_factory=lambda: {
        "gold": [], "rep": [], "roster": [], "region": [],
        "income_quest": 0.0, "income_floor": 0.0, "income_offline": 0.0,
        "exp_wages": 0.0, "exp_recruit": 0.0, "exp_heal": 0.0,
        "exp_repair": 0.0, "exp_upgrade": 0.0, "exp_bonds": 0.0, "exp_decor": 0.0, "raid_losses": 0.0,
        "outcomes": {"T": 0, "S": 0, "SB": 0, "D": 0},
        "milestones": {}, "timed_missed": 0, "breaks": 0,
    })

    # ---------------- helpers ----------------
    def region(self):
        r = 0
        for i, gate in enumerate(self.cfg["REGION_GATES"]):
            if self.rep >= gate: r = i
        return r

    def rep_tier(self):
        t = 0
        for i, gate in enumerate(self.cfg["REP_TIER_GATES"]):
            if self.rep >= gate: t = i
        return t

    def roster_cap(self):
        cap = self.cfg["TARGET_ROSTER_BY_REGION"][self.region()]
        if self.arch["spends"]:
            cap += self.cfg["CONV_EXTRA_ROSTER"]
        return cap

    def available_heroes(self, session):
        return [h for h in self.heroes if h.injured_until < session]

    def party_power(self, party):
        return sum(h.power() for h in party)

    # ---------------- session phases ----------------
    def offline_phase(self, session):
        c, log = self.cfg, self.log
        hours = min(self.arch["gap"] * 24, c["OFFLINE_CAP_HOURS"] / c["OFFLINE_RATE"])
        rate = c["OFFLINE_INCOME_PER_HOUR"] * c["OFFLINE_RATE"]
        rate *= (1 + c["UPGRADE_FLOOR_BONUS"] * self.upgrades)
        if self.arch["spends"]:
            rate *= 1.0  # staff apply to floor phase; offline base unchanged
        accrued = min(hours * rate, c["OFFLINE_CAP_HOURS"] * c["OFFLINE_INCOME_PER_HOUR"])
        if self.arch["board"]:
            accrued *= c["OPEN_BOARD_BONUS"]
            if random.random() < c["OPEN_BOARD_RAID_CHANCE"]:
                skim = accrued * c["OPEN_BOARD_RAID_SKIM"]
                accrued -= skim
                log["raid_losses"] += skim
        if self.arch["spends"] and accrued >= c["CONV_DOUBLER_THRESHOLD"]:
            accrued *= 2  # doubler on big hauls (models the robux tap)
            self.robux_spent_events += 1
        self.gold += accrued
        log["income_offline"] += accrued

    def floor_phase(self, session):
        c, log = self.cfg, self.log
        serves = self.arch["active"] * c["SERVES_PER_ACTIVE_MIN"] * self.arch["floor"]
        mult = (1 + c["UPGRADE_FLOOR_BONUS"] * self.upgrades)
        if self.arch["spends"]:
            # staff cover the un-diligent share at reduced efficiency
            manual = serves
            auto = self.arch["active"] * c["SERVES_PER_ACTIVE_MIN"] * (1 - self.arch["floor"])
            serves = manual + auto * c["CONV_STAFF_FLOOR_MULT"]
        earn = serves * c["FLOOR_INCOME_PER_SERVE"] * mult
        self.gold += earn
        log["income_floor"] += earn

    def quest_phase(self, session):
        c, log = self.cfg, self.log
        avail = self.available_heroes(session)
        n_parties = min(c["QUESTS_PER_SESSION_MAX"], max(0, len(avail) // c["PARTY_SIZE"]) or (1 if avail else 0))
        region = self.region(); tier = c["REGION_DIFF_TIER"][region]
        rep_quota = c["REP_QUESTS_PER_SESSION"]
        for _ in range(n_parties):
            party = avail[:c["PARTY_SIZE"]]; avail = avail[c["PARTY_SIZE"]:]
            if not party: break
            gap = self.arch["risk"]
            bond = c["REP_QUEST_BOND_PER_DIFF"] * (c["REGION_DIFF_TIER"][region] + gap)
            is_rep_quest = rep_quota > 0 and self.gold >= bond * 2  # keeps a cushion
            if is_rep_quest:
                rep_quota -= 1
                self.gold -= bond
                log["exp_bonds"] = log.get("exp_bonds", 0) + bond
            difficulty = tier + gap
            p = c["BASE_SUCCESS_CENTER"] - c["GAP_SUCCESS_PENALTY"] * gap
            p += 0.03 * (self.party_power(party) - c["PARTY_SIZE"])  # stronger heroes help
            if region >= 4:
                p += random.uniform(-c["WEATHER_VOLATILITY"], c["WEATHER_VOLATILITY"])
            p = max(0.05, min(0.95, p))
            reward = c["QUEST_REWARD_BASE"] * difficulty * (c["OVERREACH_GAP_MULT"] ** gap)
            # timed lucrative postings (region 4+): missed if session gap too large
            if region >= 3 and random.random() < c["TIMED_POSTING_CHANCE"]:
                if self.arch["gap"] <= c["TIMED_MISS_IF_GAP_DAYS"]:
                    reward *= c["TIMED_POSTING_BONUS"]
                else:
                    log["timed_missed"] += 1
            if random.random() < p:  # success side
                if random.random() < c["TRIUMPH_SHARE"]:
                    log["outcomes"]["T"] += 1
                    self.gold += reward * 1.4; log["income_quest"] += reward * 1.4
                    self.rep += (c["REP_PER_TRIUMPH_PER_DIFF"] * difficulty if is_rep_quest else 0)
                else:
                    log["outcomes"]["S"] += 1
                    self.gold += reward; log["income_quest"] += reward
                    self.rep += (c["REP_PER_SUCCESS_PER_DIFF"] * difficulty if is_rep_quest else 0)
                self.resources += c["RESOURCE_PER_SUCCESS"]
            else:  # failure side
                if random.random() < c["DISASTER_SHARE"]:
                    log["outcomes"]["D"] += 1
                    self.rep += (c["REP_PER_DISASTER"] if is_rep_quest else 0)
                    heal_sessions = c["CONV_INFIRMARY_HEAL_SESSIONS"] if self.arch["spends"] else c["HEAL_SESSIONS"]
                    for h in party:
                        h.injured_until = session + heal_sessions
                        cost = c["HEAL_COST_PER_INJURY"] * (c["CONV_HEAL_COST_MULT"] if self.arch["spends"] else 1)
                        self.gold -= cost; log["exp_heal"] += cost
                    rc = c["GEAR_REPAIR_COST"] * (c["CONV_WORKSHOP_REPAIR_MULT"] if self.arch["spends"] else 1)
                    self.gold -= rc; log["exp_repair"] += rc
                else:
                    log["outcomes"]["SB"] += 1
                    self.gold += reward * 0.35; log["income_quest"] += reward * 0.35
                    h = random.choice(party)
                    heal_sessions = c["CONV_INFIRMARY_HEAL_SESSIONS"] if self.arch["spends"] else c["HEAL_SESSIONS"]
                    h.injured_until = session + heal_sessions
                    hc = c["HEAL_COST_PER_INJURY"] * (c["CONV_HEAL_COST_MULT"] if self.arch["spends"] else 1)
                    self.gold -= hc; log["exp_heal"] += hc
                    rc = c["GEAR_REPAIR_COST"] * (c["CONV_WORKSHOP_REPAIR_MULT"] if self.arch["spends"] else 1)
                    self.gold -= rc; log["exp_repair"] += rc

    def upkeep_phase(self, session):
        c, log = self.cfg, self.log
        wages = sum(h.power() for h in self.heroes) * c["WAGE_PER_TIER_PER_SESSION"] * (1 + 0.25 * self.region())
        self.gold -= wages; log["exp_wages"] += wages
        # contract break risk (sloppy behavior) — cheap decision, expensive tails
        if self.arch["sloppy"] and random.random() < c["CONTRACT_BREAK_CHANCE"]:
            self.rep += c["REP_CONTRACT_BREAK"]
            self.queue_suppressed_until = session + c["QUEUE_SUPPRESS_SESSIONS"]
            log["breaks"] += 1

    def recruit_phase(self, session):
        c, log = self.cfg, self.log
        if len(self.heroes) >= self.roster_cap(): return
        odds = list(c["RARITY_ODDS_BY_REPTIER"][self.rep_tier()])
        if session <= self.queue_suppressed_until:  # damaged reputation record
            f = c["QUEUE_SUPPRESS_FACTOR"]
            odds = [odds[0] + (1 - f) * sum(odds[1:]),] + [o * f for o in odds[1:]]
        r = random.random(); acc = 0; rarity = 1
        for i, o in enumerate(odds):
            acc += o
            if r <= acc: rarity = i + 1; break
        cost = c["RECRUIT_COST"][rarity]
        if self.gold >= cost * 1.3:  # keep a cushion
            self.gold -= cost; log["exp_recruit"] += cost
            self.heroes.append(Hero(rarity))

    def upgrade_phase(self, session):
        c, log = self.cfg, self.log
        if self.upgrades < len(c["UPGRADE_COSTS"]):
            cost = c["UPGRADE_COSTS"][self.upgrades]
            if self.gold >= cost * 1.5:
                self.gold -= cost; log["exp_upgrade"] += cost
                self.upgrades += 1


    def decor_phase(self, session):
        c, log = self.cfg, self.log
        buffer = 400 + 150 * self.region()
        if self.gold > buffer * 2:
            spend = (self.gold - buffer) * 0.5
            self.gold -= spend
            log["exp_decor"] = log.get("exp_decor", 0) + spend

    # ---------------- main loop ----------------
    def run(self):
        c, log = self.cfg, self.log
        for s in range(c["SESSIONS"]):
            self.offline_phase(s)
            self.floor_phase(s)
            self.quest_phase(s)
            self.upkeep_phase(s)
            self.recruit_phase(s)
            self.upgrade_phase(s)
            self.decor_phase(s)
            self.gold = max(self.gold, 0)  # no debt in-game; floor at zero
            log["gold"].append(self.gold)
            log["rep"].append(self.rep)
            log["roster"].append(len(self.heroes))
            log["region"].append(self.region() + 1)
            for r_i in range(2, 7):
                key = f"region{r_i}"
                if key not in log["milestones"] and self.region() + 1 >= r_i:
                    log["milestones"][key] = s
        return self

# ----------------------------------------------------------------------------
# Runner, report, plots
# ----------------------------------------------------------------------------
def simulate(cfg=CONFIG, seed=42):
    random.seed(seed)
    results = {}
    for name, arch in ARCHETYPES.items():
        results[name] = [Player(arch=arch, cfg=cfg).run() for _ in range(cfg["N_PLAYERS"])]
    return results

def pctl(series_list, q):
    cols = list(zip(*series_list))
    return [sorted(c)[int(q * (len(c) - 1))] for c in cols]

def report(results, cfg=CONFIG):
    lines = ["=" * 72, "ADVENTURER TAVERN — ECONOMY SIM REPORT", "=" * 72]
    for name, players in results.items():
        g_end = [p.log["gold"][-1] for p in players]
        rep_end = [p.log["rep"][-1] for p in players]
        inc = {k: stats.mean(p.log[k] for p in players) for k in
               ["income_quest", "income_floor", "income_offline"]}
        exp = {k: stats.mean(p.log[k] for p in players) for k in
               ["exp_wages", "exp_recruit", "exp_heal", "exp_repair", "exp_upgrade", "exp_bonds", "exp_decor"]}
        tot_in = sum(inc.values()); tot_out = sum(exp.values())
        oc = {k: sum(p.log["outcomes"][k] for p in players) for k in ["T", "S", "SB", "D"]}
        n_oc = sum(oc.values()) or 1
        r3 = [p.log["milestones"].get("region3") for p in players]
        r3 = [x for x in r3 if x is not None]
        raid = stats.mean(p.log["raid_losses"] for p in players)
        missed = stats.mean(p.log["timed_missed"] for p in players)
        breaks = stats.mean(p.log["breaks"] for p in players)
        lines += [
            f"\n--- {name.upper()} (n={len(players)}) ---",
            f"  end gold  p10/p50/p90: {sorted(g_end)[len(g_end)//10]:.0f} / {stats.median(g_end):.0f} / {sorted(g_end)[-len(g_end)//10]:.0f}",
            f"  end rep   median: {stats.median(rep_end):.0f}   end region median: {stats.median([p.log['region'][-1] for p in players]):.0f}",
            f"  income mix: quests {inc['income_quest']/tot_in:5.1%} | floor {inc['income_floor']/tot_in:5.1%} | offline {inc['income_offline']/tot_in:5.1%}",
            f"  expense mix: wages {exp['exp_wages']/tot_out:5.1%} | recruit {exp['exp_recruit']/tot_out:5.1%} | heal {exp['exp_heal']/tot_out:5.1%} | repair {exp['exp_repair']/tot_out:5.1%} | upgrades {exp['exp_upgrade']/tot_out:5.1%}",
            f"  sink ratio (out/in): {tot_out/tot_in:.2f}   (healthy band ~0.55–0.85)",
            f"  outcomes: T {oc['T']/n_oc:.0%}  S {oc['S']/n_oc:.0%}  Setback {oc['SB']/n_oc:.0%}  Disaster {oc['D']/n_oc:.0%}",
            f"  region 3 reached (median session): {stats.median(r3) if r3 else 'never'}   share reaching: {len(r3)/len(players):.0%}",
            f"  avg raid losses: {raid:.0f} gold   timed postings missed: {missed:.1f}   contract breaks: {breaks:.2f}",
        ]
    # convenience parity check: whale vs grinder ceiling
    gr = results["grinder"]; wh = results["whale"]
    gr_rep = stats.median([p.log["rep"][-1] for p in gr])
    wh_rep = stats.median([p.log["rep"][-1] for p in wh])
    gr_r3 = stats.median([p.log["milestones"].get("region3", cfg["SESSIONS"]) for p in gr])
    wh_r3 = stats.median([p.log["milestones"].get("region3", cfg["SESSIONS"]) for p in wh])
    lines += [
        "\n" + "=" * 72,
        "CONVENIENCE PARITY CHECK (whale vs grinder — same behavior, spend on/off)",
        f"  time-to-region-3 (sessions): grinder {gr_r3:.0f}  vs whale {wh_r3:.0f}   -> whale saves {gr_r3 - wh_r3:.0f}",
        f"  end reputation (ceiling):    grinder {gr_rep:.0f}  vs whale {wh_rep:.0f}   -> ratio {wh_rep/max(gr_rep,1):.2f}",
        "  PASS if: whale saves time but ceiling ratio stays ~<= 1.10 (buying time, not outcomes)",
        "=" * 72,
    ]
    return "\n".join(lines)

def plots(results, cfg=CONFIG, path="economy_report.png"):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    fig, axes = plt.subplots(2, 2, figsize=(13, 9))
    colors = {"casual": "#8888cc", "grinder": "#33aa55", "gambler": "#dd8833", "whale": "#cc4477"}
    x = range(cfg["SESSIONS"])
    ax = axes[0][0]
    for name, players in results.items():
        med = pctl([p.log["gold"] for p in players], 0.5)
        lo = pctl([p.log["gold"] for p in players], 0.25)
        hi = pctl([p.log["gold"] for p in players], 0.75)
        ax.plot(x, med, label=name, color=colors[name])
        ax.fill_between(x, lo, hi, alpha=0.15, color=colors[name])
    ax.set_title("Gold on hand (median, IQR)"); ax.set_xlabel("session"); ax.legend()
    ax = axes[0][1]
    for name, players in results.items():
        ax.plot(x, pctl([p.log["rep"] for p in players], 0.5), label=name, color=colors[name])
    for gate in cfg["REGION_GATES"][1:]:
        ax.axhline(gate, ls=":", c="gray", lw=0.7)
    ax.set_title("Reputation (median) vs region gates"); ax.set_xlabel("session")
    ax = axes[1][0]
    for name, players in results.items():
        ax.plot(x, pctl([p.log["roster"] for p in players], 0.5), label=name, color=colors[name])
    ax.set_title("Roster size (median)"); ax.set_xlabel("session")
    ax = axes[1][1]
    names = list(results.keys())
    inc_keys = ["income_quest", "income_floor", "income_offline"]
    exp_keys = ["exp_wages", "exp_recruit", "exp_heal", "exp_repair", "exp_upgrade", "exp_bonds", "exp_decor"]
    bott = [0] * len(names)
    for k in inc_keys:
        vals = [stats.mean(p.log[k] for p in results[n]) for n in names]
        ax.bar([i - 0.2 for i in range(len(names))], vals, 0.35, bottom=bott, label=k.replace("income_", "+"))
        bott = [b + v for b, v in zip(bott, vals)]
    bott = [0] * len(names)
    for k in exp_keys:
        vals = [stats.mean(p.log[k] for p in results[n]) for n in names]
        ax.bar([i + 0.2 for i in range(len(names))], vals, 0.35, bottom=bott, label=k.replace("exp_", "-"))
        bott = [b + v for b, v in zip(bott, vals)]
    ax.set_xticks(range(len(names))); ax.set_xticklabels(names)
    ax.set_title("Lifetime income (left) vs expenses (right)"); ax.legend(fontsize=7, ncol=2)
    plt.tight_layout(); plt.savefig(path, dpi=110)
    return path

if __name__ == "__main__":
    res = simulate()
    txt = report(res)
    print(txt)
    with open("economy_report.txt", "w") as f:
        f.write(txt)
    plots(res)
    print("\nSaved: economy_report.txt, economy_report.png")
