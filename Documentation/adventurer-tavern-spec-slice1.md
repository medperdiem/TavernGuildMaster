# Adventurer Tavern — Slice 1 Developer Specification
*The buildable spec for the MVP. Companion to: design doc, script doc, quest tables.*
*Convention used throughout: ⚖ marks a decision where practicality and appeal were weighed — with the reasoning, and what was deliberately cut or deferred.*

---

## 1. Slice 1 Scope (locked)

**IN:** Tavern scene · recruit queue + interviews (choice-based) · Thornwood quests via the procedural assembler · encounter-beat resolution · outcome ladder · mid-quest ravens · basic floor tasks (serve/seat + eavesdrop) · offline earnings + welcome-back screen · 6 heroes (Bram, Perrin, Vex, Maren, Grunwald, Alduin) · reputation score (hidden UI until later; still accrues) · save/load.

**OUT (and why):** PvP/poaching (needs population) · regions 2–6 (content, not systems) · staff hires (nothing to automate until floor tasks prove fun) · cosmetics store (sell nothing until retention exists) · AI dialogue (beta API; scripted skeleton first) · rep tier gates (one region, nothing to gate).

⚖ *Six heroes, not four commons:* commons alone can't show the rarity ladder that drives the collection itch. Two uncommons (Grunwald for comedy/attachment, Alduin for the food/kitchen loop) cost only script lines — the systems are identical — and make the queue feel like it has a ceiling worth chasing. Cheap appeal, near-zero extra code.

---

## 2. Architecture (Luau)

**Server-authoritative everything.** Client renders and requests; server owns state. Non-negotiable on Roblox (exploiters read client memory).

```
ServerScriptService/
  GameServer.lua            -- boot, player join/leave, save/load
  Systems/
    QuestSystem.lua         -- assembly, timers, beats, ravens, outcomes
    HeroSystem.lua          -- roster, loyalty, injuries, wages
    QueueSystem.lua         -- prospect rolls, seat timers, interviews
    EconomySystem.lua       -- gold, floor income, offline calc
    FloorSystem.lua         -- patrons, serve tasks, eavesdrop
  Data/                     -- pure ModuleScript tables (no logic)
    Heroes.lua              -- archetypes, prefs, quirk defs, dialogue keys
    Dialogue.lua            -- all script-doc lines, keyed
    QuestTables.lua         -- verbs, subjects, antagonists, twists, ravens
    Constants.lua           -- EVERY tunable number, one file
ReplicatedStorage/
  Remotes/                  -- RemoteEvents/Functions (validated server-side)
  SharedTypes.lua
StarterGui/                 -- one ScreenGui per screen (see §5)
```

⚖ *Data as ModuleScript tables, not JSON/DataStore configs:* hot-reloadable in Studio, versioned with the place file, zero parsing code. The cost — a redeploy to tune constants — is acceptable pre-launch and `Constants.lua` being ONE file keeps every number findable. Defer remote config until live-ops actually exists.

⚖ *Single-place game, no teleports:* all regions are menu destinations, not 3D zones the party walks through. Quests are simulated (timers + beats), so the only built 3D space is the tavern itself. This is the single biggest practicality win in the whole design — one interior to build, decorate, and optimize — and it's invisible to players because the design already frames everything as happening "out there" via ravens and returns.

---

## 3. Save-Data Model (DataStore, per player)

```lua
PlayerData = {
  version = 1,                      -- migration key. Add from day one.
  gold = 0,
  reputation = { score = 0, record = { contractsBroken = 0, poachesDefended = 0, questsAbandoned = 0 } },
  heroes = {                        -- keyed by instanceId (GUID)
    [id] = {
      archetype = "farmhand",       -- key into Heroes.lua
      name = "Bram",
      tier = 1,                     -- upgrade stage
      loyalty = 0,                  -- 0..100
      state = "idle",               -- idle|questing|injured|resting
      injuryEndsAt = 0,             -- unix time, 0 = none
      quirkId = "stew_lover",       -- rolled at spawn from archetype's quirk pool
      quirkKnown = false,
      prefs = { gold=3, honor=1, gear=2, honesty=2 },  -- rolled in archetype band
      flags = {},                   -- memory hooks: told_truth, lied_interview, ...
      chainProgress = 0,
    }
  },
  queue = { [seat] = { archetype, prefs, quirkId, expiresAt, revealedPref } },
  activeQuests = { [id] = { spec, startedAt, endsAt, beats, ravens, choices } },
  tavern = { decor = { placedIds }, upgrades = { kitchen = 0, ... } },
  lastSeenAt = 0,                   -- offline calc anchor
  ftue = { step = 0 },              -- first-hour scripted sequence position
}
```

Rules: save on meaningful change + 60s autosave + BindToClose flush. Use UpdateAsync, never SetAsync. `version` field from day one — hero flags and quest specs WILL change shape.

⚖ *Active quests persist and resolve on next login if they finished while away:* the alternative (quests pause offline) kills the "heroes kept working" fantasy that powers the welcome-back screen. Resolution-at-login is easy — compare `endsAt` to now, run the beat resolution then. Expired ravens use their auto-resolutions (already specced). No background servers needed. Practical AND the appeal centerpiece.

---

## 4. Encounter-Beat Resolution

The core resolver. Runs at quest end (or login catch-up). No combat rendering — beats are computed, then *narrated* in the return report.

**Party supply — four axes:** MIGHT (Bram, Grunwald) · GUILE (Vex) · PRESENCE (Perrin; honesty/gold stats express here) · WARDING (Maren). Each hero contributes `tier + gearBonus` to 1–2 axes (defined in Heroes.lua). Injury/fatigue subtracts 1.

**Antagonist demand:** each antagonist row gains three fields: `primaryAxis`, `secondaryAxis`, `tags` ({fear, environmental, deceiver, ...}).

**Beats:** every quest = APPROACH → 1–2 COMPLICATIONS → CLIMAX.
- Beat check: `supply[axis] + d6 vs demand (= rank + tier modifiers + twist modifiers)`
- APPROACH tests secondary axis; CLIMAX tests primary at full demand; COMPLICATIONS test the twist's axis if present, else random of the two.
- Outcome mapping: all beats won, climax by 3+ → **Triumph** · climax won → **Success** · climax lost, ≥1 beat won → **Setback** (injuries roll) · all lost → **Disaster**.
- Ravens modify before resolution: choices add/remove beats, shift demands, or widen the d6 to d8 (volatility).

⚖ *One die roll per beat, visible-ish odds, no simulation ticks:* I considered richer per-hero action resolution — cut it. Players never watch the fight; depth they can't see is cost without appeal. All perceived depth lives in composition (supply-building) and ravens (mid-flight modifiers), which they DO see. The return report then narrates beats using script-doc return lines + beat results ("The approach went clean. The crypt door did not." ) — narrative depth at data-table prices.

⚖ *Tags do double duty:* `fear` triggers Grunwald's raven, `environmental` skips the CLIMAX combat framing, `deceiver` converts a lost PRESENCE beat into the target-lies reveal. One string array drives character moments, twist logic, and flavor. Resist adding tag #9 before shipping.

---

## 5. Screen Inventory (every screen, every tappable)

1. **Tavern (3D hub, default):** walk mode. Tappables: job board → (2), seated prospect → (3), hero (idle/resting) → (4), patron with order bubble → serve task, patron with whisper icon → eavesdrop line, door sign → (7).
2. **Job Board:** 3 posting cards (Slice 1 count). Card: posting text, difficulty band (★s), reward range, demand hint. Tap → (6). Refresh timer visible.
3. **Interview:** portrait, dialogue text, 2–3 choice buttons (NEVER free text — see §8), "Sign / Negotiate / Let them think" footer.
4. **Hero Sheet:** portrait, tier, loyalty bar, axes contribution, known quirk (or "?"), flags-driven bio lines, state.
5. **Party Picker:** posting recap + demand hint, roster grid (drag or tap-to-add, party of 1–3 in Slice 1), live supply-vs-demand readout as an odds band ("Risky / Even / Favored"), LAUNCH.
6. **Raven Popup:** raven text, 2 choice buttons, expiry ring timer. Queues if player mid-interview (never stacks two).
7. **Welcome-Back:** haul summary (gold, quest results as one line each, new prospects count), single CONTINUE. (Doubler button slot exists but is DISABLED in Slice 1 — no store yet.)
8. **Quest Return Report:** beat-by-beat narration, outcome banner, loot, hero lines (script doc), injuries if any.

⚖ *Eight screens is the floor, and the odds band on (5) is the one I fought for:* it's the costliest UI element (live recompute) but it's where the player's skill becomes visible — without it, composition feels like guessing and the core loop dies. Everything else is static layouts. Party of 1–3 (not 1–5) keeps the picker one-screen on mobile.

---

## 6. Slice 1 Constants (first-pass — ALL live in Constants.lua)

```lua
Constants = {
  -- Economy
  -- (sim-validated via economy_sim.py v6)
  FLOOR_INCOME_PER_SERVE = 3,        QUEST_REWARD_BASE = 22,        -- × difficulty × gapMult
  OVERREACH_GAP_MULT = 1.5,          -- per band above party level
  OFFLINE_RATE = 0.4,                OFFLINE_CAP_HOURS = 10,
  WAGE_PER_HERO_TIER_PER_SESSION = 8,  WAGE_REGION_INFLATION = 0.25,  -- ×(1+0.25×regionTier)
  HEAL_COST_PER_INJURY = 35,         GEAR_REPAIR_COST = 25,
  RECRUIT_COST = { common = 75, uncommon = 300, rare = 1100, legendary = 4000 },
  REP_QUESTS_PER_DAY = 3,            REP_QUEST_BOND_PER_DIFF = 24,  -- accrues silently in S1 (rep UI is S2)
  -- Pacing
  QUEST_DURATION_MIN = { 4*60, 12*60 },  -- 4–12 real minutes in Slice 1
  RAVEN_AT_FRACTIONS = { 0.33, 0.66 },   -- fire points along quest duration
  RAVEN_EXPIRY_SEC = 90,
  QUEUE_SEAT_HOURS = 36,             BOARD_REFRESH_MIN = 20,
  -- Loyalty
  LOYALTY_PERSONAL_QUEST = 10, LOYALTY_QUIRK_TICK = 3, LOYALTY_LIE_PENALTY = 15,
}
```

⚖ *4–12 minute quests, not hours:* the design doc's fiction says "days"; the MVP needs the loop provable in one playtest session. Short timers in Slice 1, stretch them when offline play is the norm. Ravens at fixed fractions of quest duration (not a scheduler): two lines of code, indistinguishable from "dynamic" to the player. These numbers are guesses BY DESIGN — the spreadsheet pass (one row per session, drag 40) validates pacing before launch; every number lives in one file for the re-tune.

---

## 7. System Behaviors (implementation order)

**Build order within Slice 1 — each step playable before the next:**

1. **Tavern shell + save/load.** Kitbashed interior, walk controls, DataStore round-trip with version field. *Done when:* rejoin restores gold.
2. **Queue + interview.** Prospect roll on join/timer, seat NPC spawn, interview UI reading Dialogue.lua branches, sign → roster. *Done when:* Bram can be signed via his scripted interview.
3. **Quest assembler + board.** QuestTables.lua roll, posting cards, party picker with odds band, timer start. *Done when:* a party launches and a timer runs.
4. **Beat resolver + return report.** Resolution at timer end, outcome ladder, injuries, hero return lines. *Done when:* Triumph and Disaster both narrate correctly.
5. **Ravens.** Fraction-scheduled popups, choice application to beats, expiry auto-resolutions, login catch-up. *Done when:* an ignored raven resolves neutrally offline.
6. **Floor tasks.** Patron spawner (see ⚖ below), serve interaction, eavesdrop lines from a rotating pool with quirk-hint injection. *Done when:* a serve pays and an eavesdrop names a queue prospect's quirk category.
7. **Offline calc + welcome-back.** `lastSeenAt` diff → capped accrual + quest catch-up + prospect arrivals, one summary screen. *Done when:* logging off mid-quest and returning shows the finished quest in the haul.
8. **FTUE sequence.** The scripted hour-one beats (design doc §11) as a step counter gating spawns: uncle's letter → scripted Bram → scripted setback quest → two-prospect choice → cliffhanger posting. *Done when:* a fresh save plays the hour without dead ends.

⚖ *Patrons: spawn seated, despawn on fade — no pathfinding.* Wandering patrons with Roblox pathfinding is a week of jank for ambiance the player stops noticing in minutes. Seated patrons with order bubbles, occasional pre-placed waypoint walks (door→table, straight line) deliver 90% of the "alive tavern" read at 5% of the cost. Revisit only if playtesters call the room static.

⚖ *FTUE as a step counter, not a cutscene system:* every hour-one beat is "when ftue.step == N, spawn X with dialogue key Y." Crude, fully sufficient, and the scripted beats already exist in the script doc. A real cutscene/camera system is Act-II-era polish.

---

## 8. Safety & Moderation Posture

- **All player expression is choice-based.** No free-text anywhere in Slice 1 — interviews, ravens, everything is buttons. This sidesteps chat moderation entirely for the core loop and is the design's stance until the AI layer (which will then use Roblox's Text Generation API with its built-in filtering, per design doc notes).
- Player-visible names: heroes use fixed names from Dialogue.lua; no player naming in Slice 1 (naming = filtering burden; defer).
- Tavern visiting (other players walking in) is OUT of Slice 1 — it arrives with PvP in Slice 3, inheriting Roblox's standard chat settings then.
- Content register: all scripts already written to all-ages tone (comic peril, no romance per platform rules, no gore). Deadly Contracts and their flavor stay out until Slice 4 with their explicit opt-in framing.

---

## 9. Definition of Done — Slice 1

A new player can: complete the scripted first hour · sign 3+ heroes through real interviews · run 10+ procedurally distinct Thornwood quests with ravens · get a hero injured and healed · discover one quirk through play · log off, return, and receive a welcome-back haul including an offline-resolved quest · fill a session with serve/eavesdrop between ravens. Zero Robux surface. Save survives rejoin and server restart.

**The one metric that matters at this stage:** do playtesters mention a hero *by name* when describing the session. If yes, the attachment engine works and everything else is tuning. If no, fix dialogue delivery before building Slice 2.

---

## 10. Known Deferrals Ledger (so nothing silently vanishes)

PvP/poaching + standing pitches (S3) · regions 2–6 + region resources (S2/S4) · reputation tiers + record UI + rep-quest cap & contract-bond UI (S2 — the cap/bond MECHANICS run silently in S1 like wages) · staff hires (S2) · cosmetics store + doubler activation (S2) · personal quest chains beyond FTUE prompt (S2) · gear system beyond flat gearBonus (S2, with Ironvein) · wage system UI (accrues silently in S1, surfaces in S2 with roster growth) · AI dialogue layer (post-S2, API maturity) · telemetry (pre-public-launch) · localization (post-launch; pun lines flagged in script doc).

⚖ *Wages accrue silently in Slice 1:* with ≤6 heroes the drain is trivial, and surfacing it in hour-one UI adds anxiety before attachment. It exists in the code (EconomySystem ticks it) so the economy's shape is real from day one — it just doesn't get a UI element until rosters grow. Practical sequencing of an appeal-sensitive system.

*End of Slice 1 specification.*
