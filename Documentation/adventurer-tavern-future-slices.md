# Adventurer Tavern — Future Enhancements: Slices 3–5
*Forward outline, NOT build specs. Each slice gets a full spec (like S1/S2) only when its entry gate is met — these are scoped intentions plus the questions live data must answer first. Sequencing here supersedes the original design-doc build order where they differ.*

---

## Sequencing Principle

Slices 1–2 prove the loops (attachment, economy, social). Slices 3–5 each bet on something that CANNOT be designed well without live data: S3 bets on how players treat each other offline, S4 on how long they stay, S5 on what veterans want. Writing full specs for these today would mean guessing at exactly the things the earlier slices exist to measure. So each slice below has an **entry gate** — the evidence required before spec-writing begins.

---

## SLICE 3 — "The Open Board" (asynchronous PvP + the gear economy)

**Entry gate:** Slice 2 live 4+ weeks · duel rage-quit metric healthy (losers' sessions don't end within 5 min) · ≥30% of active players have completed a consensual duel · duel opt-out rate below ~25% (if a quarter of players opt out, offline PvP is dead on arrival — fix S2 first).

**Scope:**
- **Standing pitches:** the pre-written defense assembled from unlocked hero knowledge; the owner's preparation substituting for presence. UI: a "pitch book" per hero, choices drawn from discovered quirks/flags.
- **Offline duels & raids:** attack rosters of offline players (village-day listed taverns only). Requires cross-server state (MemoryStore/DataStore reads of other players' public roster + pitch data). The plumbing S2 deliberately skipped — now justified by a proven duel feature.
- **The Open Board proper:** opt-in overnight listing → offline earnings bonus, raid exposure with gold skim (constants already in economy sim). Storm Mage's quirk goes live.
- **Undercutting** (high-rep leagues only): bid to snipe a bonded-but-unlaunched King's contract; victim gets bond + compensation. Ships OFF by default, enabled per-league as an experiment.
- **Ironvein Mines + the real gear system** (purchase/repair/quality tiers replacing S1's flat gearBonus) + timed postings. Gear demand gives raid losses and open-board gains something to be spent on — the PvP economy and gear economy ship together on purpose.
- **League-tinted matchmaking (maybe):** only if mixed villages measurably hurt retention; otherwise keep eligibility-rule fairness and skip TeleportService complexity permanently.

**Sim homework before spec:** extend economy_sim with offline-raid flows at real S2-observed listing rates (not guessed ones); re-verify parity ≤1.10 and that skim losses never exceed a session's median earnings.

**Open questions live data must answer:** Do players write standing pitches at all, or is it homework? (If <40% of duel participants maintain pitches, offline defense must default stronger.) Does the open board's bonus need to be bigger than 1.6× to tempt anyone once real loss is possible?

---

## SLICE 4 — "Storms and Seasons" (volatility, legendaries, live-ops)

**Entry gate:** D30 retention exists and is measurable · a cohort has reached Renowned tier · content consumption rate known (how many sessions to "finish" S3 content — this calibrates seasonal cadence).

**Scope:**
- **Stormreach Peaks:** daily weather difficulty shifts (the login-check habit), volatility band, **Deadly Contracts** with the red-seal opt-in framing (the game's only true-death mechanic, exactly as spec'd in the design doc — revisit the framing with real audience-age data before shipping).
- **Legendary heroes live:** Aldric's three-visit courtship, Ember's five-stage arc, record-gated conditions (the "never failed a contract" check gets teeth — S1–S3 histories become destiny, which is why this waits: records need time to differentiate).
- **Seasonal event framework:** temporary regions (the "Frozen Reach" pattern), exclusive heroes + decor sets, seasonal reputation ladder. This is the live-ops engine — build the FRAMEWORK once, run events from data tables forever.
- **Village social events:** festivals (hour-long cooperative-competitive income/decor contests), friendly hero duels in the square (Feather's showcase; wagers in gold, capped), rival weeks (matched-pair guild races where losing still pays).
- **AI dialogue layer:** the Roblox Text Generation API ambient tier (patron small talk, off-script interview answers, decor-aware hero comments) — per the design doc's scripted-skeleton-first rule, and only if the API has left beta gracefully. Each hero's voice note becomes the prompt; scripted triggers always override.
- **Cosmetics economy v2:** seasonal rotation discipline, the gold-decor line expanded against observed demand (the mandatory-half rule's dependency finally gets its real test at scale).

**Sim homework:** duel_sim variants for wagered friendly duels (must be provably near-fair at equal tiers); economy pass on seasonal resource inflation/starvation cycles.

**Open questions:** Is weather-checking a habit or a chore? Do festivals need scheduling around real player timezones (likely yes — cadence design is a data problem)? Does AI ambient dialogue measurably increase session length, or is it cost without effect?

---

## SLICE 5 — "Legacy" (endgame, mastery, and the long tail)

**Entry gate:** a real veteran population exists (players at content ceiling for 4+ weeks) · churn interviews/reviews indicate WHAT veterans want more of (competition vs collection vs story — this genuinely cannot be guessed; S5's emphasis should follow the data).

**Scope:**
- **The Sunken Marches:** double-twist quests (deep-roster mastery test), the "ground remembers" record-driven encounters, the uncle's-waypoint story resolution.
- **The Gilded Chain finale:** the antagonist questline (script doc beats), Sable's recruitment arc completing the defense-history reward loop.
- **Legendary tier + top-league PvP:** opt-in high-stakes league (undercutting on, tighter eligibility, seasonal crowns), the village-lane trophy.
- **Prestige / New-Guild+:** restart with one heirloom hero; the collection log (all quirks discovered) as the completionist track.
- **Persistent villages (aspiration, still not promise):** reserved-server neighborhoods for guild groups — only if S2–S4 ephemeral villages show organic recurring groups wanting it, and only as an OPTION beside default matchmaking.
- **Localization pass** (pun lines flagged in the script doc get per-language rewrites) + platform expansion polish.

**Sim homework:** prestige economy (heirloom hero must not break early-game parity for second-run players racing first-run ones); top-league duel constants under veteran knowledge levels.

**Open questions:** Does prestige cannibalize the roster attachment the whole game runs on? (Candidate answer: heirloom = the attachment made portable — test the framing with veterans before building.) Is the Marches' difficulty a satisfying wall or a quitting wall?

---

## Standing Rules Carried Forward (apply to all future slices)

1. Nothing sold may touch hero availability, party capacity, preference knowledge, or reputation. (Sim-proven rules; re-run the relevant sim on ANY new product idea.)
2. Every rule locked "open to testing" carries its falsification conditions with it — the duel-secrecy rule's pattern (evidence, signals to reopen, guardrail metric) is the template.
3. No trading, ever, per design doc. No free decor placement until the game has clearly succeeded. No sabotage mechanics at any point.
4. Each slice ships with its entry gate for the NEXT slice instrumented — telemetry for a gate is part of the preceding slice's definition of done.
5. The paper-test discipline scales: new heroes and new dialogue registers get read aloud before they get built.

*End of future enhancements outline.*
