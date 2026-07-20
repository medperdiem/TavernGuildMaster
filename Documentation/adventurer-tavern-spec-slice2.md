# Adventurer Tavern — Slice 2 Specification: The Village
*PvP layer: shared villages, tavern visiting, the King's Board (contested reputation quests), and poaching duels.*
*⚖ marks practicality-vs-appeal decisions with reasoning. This spec supersedes the Slice 1 deferral ordering — poaching moves up from Slice 3 because the village makes it cheap; offline raids and the open board move DOWN to Slice 3.*

---

## 1. Slice 2 Scope (locked)

**IN:** Village servers (6–8 plots on a lane) · plot stamping from save · tavern visiting (drinks, decor viewing, roster board) · the **King's Board** — central village board carrying all reputation quests, with contract bonds and contested claims · poaching via temptation duels (online defenders) · reputation tiers + record UI (surfacing what S1 accrued silently) · cosmetics store v1 + gold decor line (the village makes status visible, so NOW cosmetics sell) · regions 2–3 (Crypts, Gildport) · heroes 7–12 (rares) · personal quest chains + tier-up ceremonies.

**OUT → Slice 3:** offline raids, standing-pitch auto-defense, open board · league/tier-matched villages · undercutting · village festivals, friendly duels, rival weeks · trading of any kind (never, per design doc).

⚖ *Poaching ships online-only in S2:* the offline version needs cross-server reads of other players' saves (MemoryStore plumbing, staleness handling, abuse cases). Online duels need none of that — both parties are in the same server, state is already loaded. You get the marquee feature at a third of the cost, and "you can only be poached while present" is actually the gentler introduction for the player base. Standing pitches arrive in S3 when the plumbing is worth it.

---

## 2. Village Architecture

- One Roblox place. A server = a village: a short lane, **6 plots** (⚖ not 8 — fewer plots, livelier feel at Roblox's typical concurrent counts; empty plots read as dead), a village square in the middle holding the **King's Board**, a notice obelisk (event/leaderboard), and a well (pure decoration, patrons gather).
- On join: claim the first free plot, stamp your tavern onto it from save. On leave: plot clears after a grace minute.
- Server fills via default Roblox matchmaking. Friends can join each other's servers natively (free feature — "visit my tavern" works day one via the standard social flow).

⚖ *Villages are ephemeral, not persistent:* a persistent "your village, your neighbors" needs reserved servers, cross-session roommate matching, and offline-plot rendering — heavy. Ephemeral villages give 90% of the social texture (real taverns, real visits, real rivals *right now*) with zero extra infrastructure. Persistent neighborhoods are a Slice 4+ aspiration, if ever. The design already survives this: reputation, rosters, and decor persist on the PLAYER; only the lane assignment is transient.

⚖ *No tier-matched villages in S2:* custom matchmaking on Roblox means TeleportService lobby juggling — real complexity, frequent jank. Instead, fairness lives in the POACH RULES (eligibility windows, §6), not the server composition. Mixed villages are even good: a Renowned tavern on your lane is aspiration fuel for the new player who can't be poached by them anyway.

---

## 3. Plots & Decor Stamping

- The tavern template has **fixed decor anchor slots** (wall slots, table slots, shelf slots, yard slots — ~30 total). Save stores `{slotId = decorItemId}`. Stamping = clone template, fill slots. 
- Decor catalog is data (`Decor.lua`): itemId → model ref, cost, currency (gold line vs Robux line), queue-modifier tag (garden, gold, stage...).

⚖ *Slot-based decor, not free placement:* free placement needs collision checks, save bloat, grief-review (visitors seeing rude arrangements), and a gizmo UI — weeks of work and a moderation surface. Slots are a dict, stamp instantly, always look composed, and cannot spell anything. Players still express plenty through WHICH items fill WHICH slots. Free placement is the single most-requested feature you should still refuse until the game succeeds.

---

## 4. Visiting (what you can do in a neighbor's tavern)

1. **Buy a drink/meal** — ProximityPrompt at their bar; small gold to the host, tiny XP-free "visited" tick for the guest. Traffic literally feeds the host: visitors are WELCOME, which keeps the village's social temperature warm by default.
2. **Browse** — decor, trophies, tier-up banners; tap any hero idling on the floor for their public card.
3. **Roster Board** — public info only: hero names, archetypes, tiers, and the guild's reputation tier + record badges ("never broken a contract"). NOT visible: loyalty values, quirks, preference weights. ⚖ *Scouting stays shallow by design:* deep scouting (revealing quirks) would let money/time substitute for the relationship knowledge that powers duel defense. Knowledge stays earned.
4. **Challenge** — if you hold a poach token and the target is eligible (§6), open a temptation duel from their roster board.

No visitor can: touch decor, take floor tasks, interact with the host's queue prospects, or block doorways (collision off for visitors inside foreign taverns — cheap grief prevention).

---

## 5. The King's Board (central reputation quests)

**The consolidation:** ALL reputation-awarding quests now live on the village's shared King's Board in the square — royal contracts, posted under the crown's seal. Your private tavern board carries only mercenary work (gold + resources, no rep). This makes the S1 economy rule *physical*: the rep cap and bonds aren't UI abstractions, they're a real board in a real square that all six guilds read.

**Mechanics:**
- The board holds **6–10 royal contracts**, refreshed on a visible timer, generated by the same assembler (quest tables doc) at difficulty bands spanning the village's player range.
- Taking one: pay the **contract bond** (24 × difficulty, per economy v6) at the board → the posting is marked "Sworn: {GuildName}" for everyone to see → run it from your party picker as normal. Completion awards rep (cap of 3 rep quests/day/player enforced at the board — the clerk NPC refuses a 4th: "the crown's ink is dry for you today").
- **Contested claims:** 1–2 postings per refresh are **Open Contracts** (marked with crossed banners): multiple guilds may bond the SAME posting; first completion takes full rep + reward, others get bond back + a consolation gold cut. The board shows who's sworn onto it — visible races.
- Failure on a sworn contract: bond forfeit + the rep penalty, publicly logged on the obelisk for the village day. Stakes are social, not just numeric.
- **Anti-squatting:** a sworn contract must LAUNCH (party assigned and away) within 15 minutes, or the claim releases automatically — bond refunded minus a 25% penalty, posting reopens, and the release is noted on the obelisk. One timer kills the deny-by-bonding exploit; the penalty makes speculative claiming a losing habit without punishing genuine "got distracted" moments too harshly.

⚖ *Contested = shared posting + first-completion, nothing more:* no live progress bars, no interference, no seeing the rival's party. First-past-the-post needs one server-side timestamp compare. The DRAMA comes from the board's "Sworn:" tags and the obelisk log — information display, which is cheap, rather than interaction systems, which are not. Racing feels head-to-head; implementation is two guilds independently running normal quests.

⚖ *"King's Quests" framing earns its keep:* one fiction (royal contracts) explains the cap ("the crown issues limited seals"), the bond ("sworn surety"), the public board, and why mercenary work pays no rep ("the crown didn't ask"). Zero mechanics added; every existing economy rule becomes diegetic.

---

## 6. Poaching: Temptation Duels

**Tokens & eligibility (the grief firewall — all server-checked):**
- 2 poach tokens/day (do not stack). Target must be: online in your village · above the new-player protection window (account-age + progress gate) · within ±1 reputation tier of you · not poached (by anyone) in the last village day · hero not under fresh-contract grace · not the Dragonheir at max loyalty (quirk) · defender has not disabled duels in settings (⚖ an opt-out toggle ships day one — the cheapest possible insurance against the feature souring anyone; opting out also disables your own attacking).

**The duel (30–45 seconds, both players present):**
- Attacker opens from the roster board → defender gets an accept/decline prompt (decline = attacker's token refunded, no shame mechanic). ⚖ *Consent prompt in S2:* forced duels on a fresh PvP population is how you earn bad reviews; make it opt-in per-duel now, revisit when standing pitches exist.
- **Three alternating rounds.** Each round: attacker plays 1 of 3 drawn **pitch cards**, defender responds with 1 of 3 drawn **bond cards**.
  - Pitch cards are generic + public-info driven: "Double their wage" (costs attacker real gold if they win!), "Our record is spotless" (only drawable if true), "A finer stage awaits" (only if attacker owns that decor tag)...
  - Bond cards are RELATIONSHIP-driven: drawn from the defender's unlocked knowledge — discovered quirk ("she hates crowds — our queue stays short"), memory flags ("I told him the truth on day one"), personal-chain progress, loyalty tier. More knowledge = better draw pool.
- Server scores each round against the hero's actual hidden weights + loyalty handicap. Round results show as the hero's reaction line (script doc registers — the hero literally talks through the duel).
- Outcome: attacker wins → hero transfers (attacker pays any promised costs; defender receives compensation gold + a **revenge token**: one free duel-back within 3 days). Defender wins → attacker's token spent, defender's hero gains loyalty, both see one revealed hint about why.

⚖ *Cards are buttons + data tables — the whole duel is one screen:* no animation system, no timing skill, no physics. All depth is in draw-pool composition, which reuses systems already built (quirks, flags, loyalty). AFK/disconnect mid-duel = best remaining card auto-played, never a forfeit.

**RULE — hidden preferences are unscoutable (locked, but open to testing):**
Simulation (duel_sim.py, informed-attacker mode) shows that an attacker who knows a hero's top hidden preference gains ~40 points of winrate — more than the entire loyalty axis is worth. Defense vs an informed attacker: 8–67% at partial knowledge across the loyalty range; even devoted + full knowledge drops 97% → 87%. If weight-scouting existed, the duel would stop being "how well do you know your hero" and become "who scouted first." Therefore:
1. Duel result hints reveal RELATIONSHIP facts ("she remembered you kept the queue short"), never preference facts ("she values gold most"). Hint content is the firewall; token limits and target cooldowns only throttle probing.
2. Scouting abilities (Shadow Agent, Sable's kit) are scoped to LOGISTICS — roster states, injuries, active bonds, timing intel — never preference weights.
3. Archetype tendencies remain public and learnable (Mercenaries lean gold); per-hero rolled weights and quirks on top of the tendency are the permanent secret. Reading tendencies and result patterns IS the attacker's intended skill.
4. No purchasable or grindable capability may reveal a weight. The one sanctioned exception to explore later: a rare signature move (e.g., Sable's weekly) — the sim shows informed attacks only decide fights against low-loyalty targets, so it functions as a finisher on the already-vulnerable, not a veteran-killer.
**Testing clause:** this rule is falsifiable in playtest. Revisit if: (a) attackers report duels feel like pure guessing (tendencies too weak a signal — consider revealing ONE axis after a completed duel against that specific hero), or (b) probing meta emerges despite hint scoping (tighten cooldowns first, hint pools second). Any relaxation must re-run duel_sim.py informed-mode and keep devoted-defense ≥ 85%.

⚖ *Hero transfer is the scariest line in this spec — kept because compensation + revenge token + eligibility walls make it survivable, and because "you can lose what you love" is the entire emotional stake of the game. If playtests show it's too hot: first lever is narrowing eligibility (same-tier only), second is a "loan" variant (hero returns after N days). Do NOT remove transfer before trying both.*

---

## 7. New Screens

9. **Village lane** (3D, extends the hub) — plots, square, board, obelisk.
10. **King's Board UI** — contract cards with Sworn tags, bond-payment confirm, daily-seal counter (X/3), refresh timer.
11. **Roster Board** (per tavern) — public cards + Challenge button.
12. **Duel screen** — hero portrait center, reaction line, 3 cards bottom, round pips, timer ring.
13. **Reputation panel** — tier ladder, record badges, obelisk log tab. (Surfaces S1's silent accrual; the "wages" line item also becomes visible here in the ledger tab.)

## 8. Data Model Additions

```lua
PlayerData additions:
  poachTokens = { count, resetAt },
  revengeTokens = { {targetUserId, expiresAt} },
  duelsDisabled = false,
  dailySeals = { used, resetAt },          -- rep-quest cap tracker
  compensationLog = {},                     -- audit trail for support
Server (village-scoped, not saved):
  kingsBoard = { postings, swornMap, refreshAt },
  obeliskLog = { entries (village day) },
```

## 9. New Constants

```lua
POACH_TOKENS_PER_DAY = 2, POACH_TIER_RANGE = 1, POACH_TARGET_COOLDOWN_H = 20,
NEW_PLAYER_PROTECT_DAYS = 7, FRESH_CONTRACT_GRACE_H = 48,
DUEL_ROUNDS = 3, DUEL_CARD_CHOICES = 3, DUEL_ROUND_SEC = 15,
COMPENSATION_MULT = 1.0,        -- × hero's recruit cost, paid to victim
REVENGE_TOKEN_DAYS = 3,
KINGS_BOARD_SIZE = 8, OPEN_CONTRACTS_PER_REFRESH = 2, BOARD_REFRESH_MIN = 30,
VISITOR_DRINK_GOLD = 4,
```

## 10. Safety Posture Additions

Village chat = Roblox standard chat with platform filtering (nothing custom). All duel/board expression remains buttons. Obelisk log lines are template-generated (no free text ever rendered to others). Duel opt-out honored everywhere. Report flow: rely on Roblox's native report on the player; nothing in-game collects text to moderate.

## 11. Build Order & Definition of Done

1. Lane + plot stamping (slot decor) → *two accounts see each other's taverns.*
2. Visiting interactions (drink, browse, roster board) → *a visit pays the host.*
3. King's Board + bonds + seals + obelisk → *a rep quest can ONLY be taken at the board; 4th seal refused.*
4. Contested contracts → *two accounts race one posting; loser gets bond back.*
5. Duel screen + card system + transfer/compensation → *a hero changes hands, victim gets paid + revenge token, reaction lines play.*
6. Reputation panel + record badges → *S1's silent numbers visible.*
7. Cosmetics store v1 + gold decor line → *first Robux surface, plus the gold sink the economy sim assumes.*

**Done when:** a village of 3+ real players produces, unprompted, one drink purchase, one board race, and one consensual duel per session — and the duel loser's session doesn't end within 5 minutes (the rage-quit metric; watch it above all others).

## 12. Sim Note

Before building §6: add a duel module to economy_sim.py (attacker/defender knowledge levels vs loyalty) to tune round scoring so that max-loyalty defense wins ~85%+, fresh-contract-expiry heroes are genuinely contested (~50/50), and money-only pitches lose to full-knowledge defense at every loyalty level above low. The card system's health is testable before any Luau exists.

*End of Slice 2 specification.*
