# Adventurer Tavern — Game Design Document
*A Roblox tavern-management and hero-recruiting game with social PvP*
*Design reference — v1.0*

---

## 1. Concept & Pillars

You inherit a shabby tavern that doubles as an adventurers' guild. Heroes wander in as patrons; you learn what each one values, win them over, send them on quests, and grow the tavern into a renowned guild hall — while rival players try to tempt your heroes away, and you theirs.

**Design pillars:**
1. **Every hero is a puzzle.** Hidden preferences and quirks make recruiting a discovery game that wikis can't fully solve.
2. **The tavern is the hub and the trophy.** Every system (recruiting, recovery, cosmetics, offline economy, queue odds) routes through the physical tavern floor, which other players visit.
3. **Honesty is a mechanic, not a lecture.** Lying works short-term and costs long-term. Trust builds slowly, breaks fast.
4. **Risk is always opt-in.** Overreach quests, deadly contracts, the open board — the player chooses every gamble. Safety is the free default.
5. **Complexity unlocks at the speed of attachment.** Systems are introduced as story moments, gated behind the player caring first.

**Platform compliance note:** No dating/romance content (prohibited by Roblox Community Standards). No permadeath ambushes. No paywalled safety. Monetization is cosmetics, convenience, and offline-earnings amplification — never poach power or raw hero strength.

---

## 2. Hero System

### 2.1 Preferences
Every hero weighs four base preferences when deciding to sign, stay, or leave:
- **Gold** — pay, contract terms, visible wealth
- **Honor** — guild reputation score and record
- **Gear** — equipment quality you provide
- **Honesty** — how truthfully you've dealt with them and others

Plus **one hidden quirk per individual hero** — a fifth, weirder condition rolled per-hero (not per-archetype) so no wiki fully solves recruiting. Quirks hook into other systems: decor, kitchen, queue length, poach history, open-board setting.

### 2.2 Loyalty
- Earned through **actions**, never idle time: completing personal quests, honoring contract terms, healing them when injured, respecting their quirk.
- Acts as the defensive stat in poach attempts.
- Drops on: broken promises, disaster quests they were sent into knowingly underpowered, quirk violations.

### 2.3 Roster (by rarity)

**Common — bread and butter (cap early, upgrade cheap, become support)**
| Hero | Leans | Quirk flavor example | Upgrade arc |
|---|---|---|---|
| Farmhand Fighter | Gold | Signs faster if tavern serves stew | Pitchfork → Sword → Militia Captain (trains other commons faster) |
| Wandering Minstrel | Honesty | Needs a stage/music in tavern | Busker → Bard → Songweaver (boosts customer income while home) |
| Street Rogue | Gold, Gear; suspicious of squeaky-clean guilds | Won't sign if queue > 3 (hates crowds) | Pickpocket → Burglar → Shadow Agent (scouts rival taverns) |
| Village Cleric | Honor, Honesty; refuses bribes | Loyalty rises when guildmates return injured | Acolyte → Priest → High Cleric (reduces quest failure roster-wide) |

**Uncommon — specialists**
| Hero | Leans | Quirk flavor | Upgrade arc |
|---|---|---|---|
| Cowardly Barbarian | Gear (armor = safety), low Honor | Flees temptation events — accidentally poach-proof | Nervous → Reluctant → Reckless (a courage story arc) |
| Gourmet Knight | Honor, swayed by food | Kitchen upgrades count double toward loyalty | Hungry Squire → Feast Knight → Paladin of Plenty (boosts offline dining income) |
| Grizzled Mercenary | Gold; respects honesty (been burned) | Walks instantly if you break ANY hero's contract | Sellsword → Veteran → Warmaster (second simultaneous quest slot) |
| Hedge Witch | Gear (reagents), Honesty; distrusts flashy wealth | Prefers garden/nature decor | Herbalist → Witch → Archdruid (brews quest-speed potions) |

**Rare — build-arounds**
| Hero | Leans | Quirk flavor | Upgrade arc |
|---|---|---|---|
| Disgraced Noble | Honor above all | Won't join a guild that poached recently | Exile → Knight-Errant → Redeemed Countess (major reputation-gain boost) |
| Treasure-Mad Dwarf | Gold, Gear | Loyalty tied to gold visibly displayed in tavern | Prospector → Delver → Kingsminer (increases all quest loot) |
| Masked Duelist | Gear, Honesty | Reveals face only at max loyalty (cosmetic moment) | Mystery Challenger → First Blade (specialist at winning temptation duels — defends other heroes) |
| Storm Mage | Gear, Honesty; ignores gold | Loyalty drops while open-board risk setting is on | Apprentice → Stormcaller → Tempest Archmage (unlocks top quest regions) |

**Legendary — chase heroes**
| Hero | Leans | Quirk | Upgrade arc |
|---|---|---|---|
| The Retired Hero | Honor + Honesty at extreme weights; ignores gold/gear | Only considers guilds that have NEVER failed a contract | Retired → Returned → Legend Reborn (passive loyalty aura for whole roster) |
| Dragon-Blooded Orphan | Modest everything, 2x loyalty gain | Un-poachable forever once loyalty maxes | 5 stages → Dragonheir (strongest quester in game; the long-investment payoff) |
| The Rival Poacher | Gold, Honesty (a professional) | Only appears after you defend several poach attempts | Poacher → Guildbreaker → Head of Security (permanent defense bonus) |

Upgrades come from **personal quest chains** (procedurally assembled — see §4), so they land as story beats. Each tier-up is a visible ceremony in the tavern: new outfit, new idle animation, patrons cheer — feeding the status-cosmetics economy.

---

## 3. Reputation

A public, earned ledger of the guild's honor.

- **Rises:** completed contracts, honored terms, defended poaches, region milestones.
- **Falls:** abandoned quests, broken promises (costs far more than good deeds earn), poaching others (lightly — a deliberate identity trade-off: poach guilds trade rep for roster power; honor guilds climb faster to gates).
- **Score vs. Record:** the *score* gates regions and queue quality; the visible *record* ("never broken a contract", "defended 12 poaches") gates specific hero quirks. Money can't launder a stained record.
- **No offline decay.** Casual-friendly; loss only from choices.
- **Tier ladder (named, not raw numbers):** Unknown → Local → Respected → Renowned → Legendary. Tier-ups are celebration screens visible to tavern visitors.

---

## 4. Quests

### 4.1 Player role: quartermaster
Jobs arrive on the tavern job board, posted by NPC patrons. Each posting shows difficulty band, region, and demand hints ("undead in the crypts" → clerics help; "delicate negotiation" → honesty heroes). The player assembles the party, picks gear, optionally adds one consumable. Composition-vs-hints is the skill. Target: ~30 seconds of real thought per assignment.

### 4.2 Outcome ladder (no binary pass/fail)
1. **Triumph** — bonus loot, big loyalty/XP
2. **Success** — standard reward
3. **Setback** — partial reward, heroes injured, need tavern rest (feeds Cleric/kitchen/recovery loop)
4. **Disaster** — wounded and shaken heroes, chain progress stalls, gear may break, loyalty hit

**No permadeath for signed heroes.** "Gravely wounded" state instead: long recovery, resource cost to heal, loyalty hit. True death exists ONLY in opt-in, clearly labeled **Deadly Contracts** (Stormreach+) with enormous rewards — always the player's chosen gamble, never an ambush.

### 4.3 Overreach economy
Party screen shows a rough risk estimate (odds band, not exact math). Rewards scale hard with quest-level-above-party-level. One dial creates the whole risk economy: grinders play safe, gamblers punch up.

### 4.4 Procedural generation
Stacked template layers:
- **Verb:** rescue / escort / hunt / retrieve / investigate / negotiate
- **Subject + antagonist:** rolled from region-themed tables
- **Twist modifier(s):** changes demands — "the target lies" (honesty shines), "cursed ground" (clerics), "collapsing tunnels" (speed > strength)
- **Difficulty** = region tier + antagonist rank + twist count
- **Reward** = difficulty × party-gap multiplier

Text assembles from slots: "Rescue the merchant's daughter from bandits in Thornwood — but the ransom note is a lie." A few dozen entries per table → thousands of distinct-feeling quests. **Personal chains** pin slots to a hero ("antagonist: the Duelist's old rival") to feel authored.

### 4.5 Mid-quest decision events (the active-play core)
Quests are **interruptible, not fire-and-forget**. While a party is out, ravens arrive with decision points generated by the same template system that builds the quest:
- **Risk forks:** "The tunnel splits — press deeper for the vault, or take the safe haul?" (shifts the outcome ladder up or down a band)
- **Character moments:** "The Barbarian's frozen up. Send encouragement (costs gold) or trust the Cleric to steady him?" — drawn from the party's actual archetypes, quirks, and loyalty, so choices feel personal and reinforce attachment
- **Twist reveals:** the quest's hidden twist can surface mid-run ("the ransom note is a lie — press the negotiation or spring the ambush?"), rewarding players who read their party's strengths

Rules of thumb: 1–3 decisions per quest depending on length; with 2–3 parties running concurrently, a decision arrives every minute or two — converting quest wait time into the game's primary active loop. Decisions are optional-but-advantaged: an unanswered raven auto-resolves neutrally after a timer, so short-session and offline players are never punished, but attentive players consistently outperform. Choices and their outcomes feed the dialogue memory hooks (§13.2): "You called the deeper tunnel. I still don't know how you knew."

---

## 5. Regions (progression ladder)

Each region = a theme + a signature demand + a new mechanic + a resource fed back to the tavern + a cosmetic set.

| Region | Theme | Signature demand | New mechanic | Feeds back |
|---|---|---|---|---|
| **Thornwood** (starter) | Bandits, wolves, lost travelers | None (any party works — the teaching region) | Basic loop | Food ingredients; source of common walk-in recruits |
| **The Old Crypts** | Undead, curses | Cleric / honesty heroes ("the dead sense deceit") | Cursed twists; injury types needing rest | Relics (decor) |
| **Gildport** (trade city) | Smugglers, cons, merchant disputes | Negotiation/investigation verbs; honesty + gold stats | Rival guild NPCs introduced | Trade contacts (queue boosts) |
| **Ironvein Mines** | Collapse, deep-dwellers | Gear quality > levels | Timed postings (board expiry) | Gear materials |
| **Stormreach Peaks** | Elementals, dragon foothills | High volatility; gambler's region | Daily weather shifts difficulty; Deadly Contracts debut | Enchantments |
| **The Sunken Marches** (endgame) | Ancient ruins | Every quest rolls TWO twists — deep rosters beat one stacked party | Legendary chains resolve here | Legendary catalysts |

Unlocks gated by **reputation tier**, not grinding — honor-economy heroes are strategically valuable. Seasonal events = temporary regions (e.g., two-week "Frozen Reach") with exclusive heroes/decor — the live-ops engine.

---

## 6. Recruit Queue

Prospects physically sit in the tavern (bar, fireplace), not a menu.

- **Who appears:** weighted roll. Reputation tier sets rarity odds; tavern state adds modifiers (stage → performers, gold decor → dwarves, garden → witches). Decor is mechanically meaningful *without* selling power (it nudges who visits, not how strong they are).
- **Wait timer:** prospects leave after ~1–2 real days. Gentle urgency, login hook.
- **Seats:** start with 2; expand via Gildport contacts and one purchasable expansion.
- **On sit-down:** archetype + ONE visible preference shown. The rest learned via a short interview dialogue — your questions, and your honesty answering theirs, are the first loyalty interaction. Lie and sign → they start suspicious; the Mercenary walks entirely.
- **Flourishes:** high rep spawns *referred* prospects (quirk pre-revealed — a signed hero vouched). Defended poaches sometimes convert attackers' heroes into legitimate prospects. Commons always trickle in — the queue is never empty.

**The closed loop:** quests → reputation → better queue → better recruits → harder regions → rarer resources/decor → decor shapes queue again. Everything crosses the tavern floor.

---

## 7. PvP: Poaching

- **Scarce-token duels:** limited poach tokens per day. Not free harassment.
- **Temptation event:** ~30-second interactive minigame. Attacker pitches on the hero's preferences; defender counter-pitches in real time using what they actually *know* about their own hero. Knowledge = defensive skill.
- **Offline defense:** hero auto-defends with accumulated loyalty + a pre-written "standing pitch" assembled from unlocked knowledge. Preparation substitutes for presence; offline players are slightly weaker, never helpless.
- **Protection:** fresh contracts have a grace window; new players untouchable for first days; matchmaking by guild level; max-loyalty Dragonheir is permanently un-poachable.
- **Failure costs the attacker:** public reputation hit + defender receives compensation and/or a counter-raid/revenge token. A duel both sides can profit from, not griefing.
- **Losing stings, never wipes:** one hero at a time, never your accumulated progress.
- **Open Board (opt-in risk):** list your tavern publicly overnight → offline earnings rate jumps significantly, but a successful raid skims some accumulated gold. Visible risk, meaningful upside, safe default free. (Storm Mage's quirk hates this setting — a real trade-off.)

---

## 8. Offline Economy

While away: customers keep buying (gold), signed heroes keep questing (loot/rep at reduced rate), word-of-mouth builds (prospects queue up). Accrual at a **reduced rate vs. active play**, capped after N hours (return daily, not weekly).

**Welcome-back screen** shows the accumulated haul — tables of patrons, stacked till, two adventurers waiting — and hosts the monetization moment: one-tap Robux doubler/tripler of the haul. Framed as *amplifying a win*, never avoiding a loss.

---

## 8b. Tavern Floor Activities (between-decision play)

While parties are out and between raven decisions, the player is the **host**. Light, pleasant tasks on the tavern floor — the starting point for moment-to-moment engagement:

- **Serve & seat:** take orders, deliver stew and ale, seat incoming patrons. Small gold per task; busier floor = more tasks = more income.
- **Keep the peace:** break up the occasional brawl before it damages decor.
- **Eavesdrop:** patrons gossip — dropping quest hints, quirk clues about queue prospects, and rival-guild intel. Floor activity feeds the discovery loop, not just the till.
- **Fireside chats:** walk over to recovering or idle heroes for dialogue scenes (where memory-hook lines fire). Attachment content the player *chooses* to seek out, never a popup.
- **Putter:** decorate, rearrange, review the quirk-discovery log, write standing pitches, visit rival taverns to scout.

**Session shape:** return → welcome-back haul → board & party assignment (~5 min) → rolling rhythm of raven decisions every 1–2 minutes while hosting, chatting, and puttering — with temptation duels as occasional spikes. Target: 15–30 minutes of occupied play, all inside the tavern where cosmetics live.

**Convenience monetization hook:** floor tasks must be genuinely optional. Players who enjoy them earn the income and clues directly; players who tire of them can hire **staff** — a barmaid who auto-serves, a bouncer who auto-handles brawls, a gossipy regular who surfaces one eavesdrop clue per session automatically. Staff are Robux (or premium-currency) purchases that *automate, never exceed*: hired staff earn slightly less than attentive manual play, so hands-on players are never strictly worse off, and staff double as visible tavern characters (status + charm, not just automation). This is the same principle as the offline upgrades — sell back time, never sell power.

---

## 8c. Economy: Income, Expenses, Disruption, Grind Relief

**Income (in order of appearance):** floor income (patrons buying food/drink — small, constant, scales with upgrades and traffic) · quest rewards (the main engine — gold + loot × difficulty × overreach multiplier) · offline accrual (reduced-rate, capped) · region resources (relics, gear materials, trade contacts, enchantments — **never purchasable**, earn-only) · open-board bonus rates · seasonal payouts.

**Deliberate split:** gold is the liquid currency and the ONLY thing convenience purchases touch. Region resources stay grind-only so progression can never be fully bought.

**Expenses (heavier than tycoon norm — expenses create decisions):**
- Recruiting: signing bonuses scale steeply with rarity
- **Wages/contract renewals:** periodic drain proportional to roster size — the keystone. Converts the roster from pure asset into a portfolio with carrying costs; makes hoarding costly and roster choices real
- Healing & recovery: injuries cost gold AND time; disasters cost a lot of both
- Gear: purchase + repair after setbacks (the Ironvein loop)
- Tavern upgrades, decor, consumables (potions)
- PvP: poach tokens' opportunity cost; compensation skimmed if raided off the open board

**Disruptions (keep the economy from being a solved spreadsheet):**
- Outcome-driven: a Disaster is a triple hit — no reward, healing costs, injured hero stops earning while wages continue
- Systemic: timed Ironvein postings expire; Stormreach weather swings daily rates; open-board raids skim accumulated gold
- Self-inflicted: breaking a contract to save gold risks Korr's walkout + reputation damage that suppresses future queue quality — cheap decision, expensive tails
- Seasonal: events inflate one resource, starve another — periodic strategy shifts

**The grind→convenience chain (the honest statement):** every expense also costs TIME; convenience purchases buy back time, never outcomes. Healing costs gold → infirmary upgrade halves the COST (recovery TIME is untouchable — sim-proven throughput leak). Wages squeeze roster size → purchased BENCH slots hold extra heroes for collection and floor charm, but party capacity is fixed for everyone. Floor income needs presence → staff automate below manual rates. Offline caps limit accrual → doubler + persistent upgrades raise the haul. Gear wears → workshop slows wear. **In every case the free path reaches the identical place, slower.** That is the line between convenience and pay-to-win — and the audit defense.

**Tuning discipline:** free play must be genuinely pleasant at Slice 1; expenses grow into mild friction by Act III when attachment justifies the trade. Friction before attachment reads as a shakedown; after, as a fair trade. Region resources stay outside the store forever so all progression points at something money never touched.

**FINAL ECONOMY RULES (sim-validated, economy_sim.py v6):**
1. **Reputation cap + contract bonds.** Max 3 reputation-awarding quests per day. Registering a quest as a *reputation contract* requires a gold bond scaling with difficulty ("the guild stakes its name"). Unbonded quests run as mercenary work: gold and resources only, no rep either way. The daily "which quests deserve our name" choice is a core decision.
2. **Why:** raw throughput caps failed in simulation — any convenience touching hero AVAILABILITY (healing speed, party-capable slots) compounds into progression (parity ratios 1.9–2.5). Bonds route the spender's advantage through gold — the intended, bounded channel. Validated parity: 1.10 (whale saves ~3 sessions to region 3, identical ceiling).
3. **Gold scarcity constants:** wages 8/tier/session ×(1+0.25×region tier — wage inflation keeps roster size a live decision forever), heal 35, repair 25, recruit 75/300/1100/4000 by rarity, bond 24×difficulty.
4. **The mandatory-half rule:** mandatory sinks (wages, healing, repair, recruiting, bonds, upgrades) consume ~50% of income — no player is ever blocked from the fun verbs. The **aspirational gold-decor line** (gold-priced, distinct from Robux cosmetics) absorbs surplus above a comfort buffer, holding total sink ratio ~0.9+. End-of-arc gold: ~750–1,450 vs 2,200–4,800 untightened; progression pacing unchanged.
5. **Dependency flag:** rule 4 assumes players WANT the gold decor. The desire is designed (Brokka's displayed-gold quirk, queue modifiers, visitor status) but must be confirmed in playtest.
6. **Convenience product definitions (locked):** infirmary = heal-cost reduction · roster expansion = bench slots · staff = below-manual floor automation · offline doubler & persistent offline upgrades. NOTHING sold may touch hero availability or party capacity.

---

## 9. Monetization

**Sell:** 
- Cosmetics (primary — see §10)
- Offline-earnings boosts: one-tap doublers + persistent upgrades (Head Chef = permanent offline dining income; Quartermaster = +1 offline quest slot; recruit-queue seats)
- Bench roster slots (collection + floor charm; party capacity fixed for all players)
- Infirmary (halves healing COST, never time)
- Scouting lens (reveals one preference early — convenience, not power)
- Tavern staff hires (§8b): automate floor tasks at slightly-below-manual efficiency — sell back time, never power
- Seasonal pass: cosmetic + mild-convenience tracks

**Never sell:** poach power, hero strength, safety/protection, loot-box heroes. Basic offline protection (tavern lock) is free and automatic.

**Timing:** zero monetization in hour one. First offer = session two's welcome-back doubler, once the tavern is *theirs*.

---

## 10. Cosmetics (low-modeling-skill strategy)

1. **Recolors & materials** — one asset, many rarity tiers (gold/obsidian/neon/seasonal) via Color + Material properties. Zero modeling.
2. **Particles & lighting** — ParticleEmitters + PointLights: blue fire, floating embers around legendaries, rune-glow trim. Motion/glow reads more premium than mesh detail.
3. **Kitbashing free Creator Store assets** into themed decor sets (pirate corner, winter feast table). Vet toolbox assets — delete embedded Scripts.
4. **Sets & seasons** — bundle 5-piece sets; monthly rotation. Scarcity is free to build.
5. **Hero accessories & status markers** — hats, weapon trails, "☆ Champion ☆" nameplates (TextLabels). Status sells regardless of polycount.

Every cosmetic doubles as status display (other players visit your tavern) AND many nudge queue odds (§6) — visible, meaningful, not pay-to-win.

Start: recolors + particles + one seasonal set. Invest further only after revenue data.

---

## 11. First Hour (onboarding)

**Job of hour one: make the player care about one specific hero before any system is formally explained.** Every system enters as a story moment, never a tutorial popup. No choice in hour one can be meaningfully wrong.

- **0–5 min — Inherit, don't build.** Shabby-but-alive tavern, uncle's letter, fire crackling. Scripted Farmhand Fighter at the bar (visible pref: gold, tiny ask). Dialogue teaches honesty-in-miniature (he asks if the guild is doing well; truth vs. puffery, consequence shown quietly). First hero signed < 5 min.
- **5–15 min — First quest, guaranteed drama.** Scripted easy Thornwood job; assign your one hero (teaches the *motion*). Tavern lives while he's away (stew sale, coins, second prospect arrives). Quest returns as a scripted **setback** — success, but he limps home. Teaches graduated outcomes + recovery loop + creates attachment. His "worth it, boss" line does the onboarding.
- **15–30 min — First real decision.** Two prospects (e.g., Cleric vs. Rogue), gold for only one. Cleric heals the limper faster; Rogue unlocks a fatter posting. Both outcomes fine; the other returns to the queue later.
- **30–60 min — Widen, then release.** Second quest with a composition hint → first tavern upgrade purchase → first personal-quest prompt (introduces chains) → reputation meter appears ONLY now (confirms behavior already done, doesn't assign homework). End on a soft cliffhanger: sealed courier posting one band above safe, big reward — the first overreach gamble. Player logs off with a plan.

**Hidden in hour one:** poaching (learned via story beat — a rival NPC poaches from *someone else*), quirks (discovered when one fires), open board, regions beyond Thornwood, ALL monetization.

---

## 12. Progression Arc — Hours 1 to 40

The arc is structured in five acts. Times are approximate for an engaged player; systems gate on reputation tiers and story beats, not literal clock hours.

### Act I — "The Inheritance" (Hours 1–4) · Rep: Unknown → Local
**Player state:** 1–3 commons, Thornwood only, tavern shabby.
**What unlocks:** Recovery/rest loop (h1), second queue seat used (h2), first quirk fires (h2–3 — e.g., the Rogue refuses to sign because the queue is full; the game names the concept only after it happens), kitchen upgrade (h3), first offline session between sessions 1–2 → welcome-back screen + first (skippable) doubler offer.
**Story beats:** Uncle's letter hints at "the guild's old rival." A traveling NPC guildmaster visits, appraises the tavern condescendingly — planting the reputation motive.
**Emotional target:** *This place is mine, these people are mine.*

### Act II — "A Name in the Valley" (Hours 4–10) · Rep: Local → Respected
**Player state:** 4–6 heroes incl. first uncommons; Crypts unlock ~h5.
**What unlocks:** Crypts (first specialization gate — the player's first *failed* party comp is designed to happen here, gently: a no-Cleric party takes a Setback with clear feedback), cursed injuries, first personal-quest chain completed → first hero tier-up ceremony (~h6, ideally the Farmhand → Sword Fighter, closing the arc of the hero they bonded with in hour one). Poaching introduced as *spectacle* ~h7: the player witnesses a rival NPC guild's temptation event against another NPC guild. At h8–9 the player receives their first poach attempt — against their *strongest-loyalty* hero (rigged to be winnable), with the standing-pitch tutorial immediately before.
**Story beats:** The condescending guildmaster returns, surprised. First referred prospect arrives.
**Emotional target:** *We're becoming somebody — and somebody noticed.*

### Act III — "Gildport Games" (Hours 10–18) · Rep: Respected
**Player state:** 7–10 heroes, first rare (likely Dwarf or Duelist), two quest parties running concurrently.
**What unlocks:** Gildport ~h10 (social verbs; heroes who were "weak" become stars — the roster-depth lesson), rival PLAYER guilds now visible (leaderboard, tavern visiting), poach tokens granted ~h12 (player can now attack; the reputation cost is explained the moment they hover the button — the game's central identity choice made explicit), Ironvein ~h15 (gear economy + timed postings), open board unlocked ~h16 with a one-night free trial.
**Story beats:** The Rival Poacher NPC begins appearing in the background of Gildport quests. A quest chain reveals *why* the uncle left.
**Emotional target:** *I have a strategy now.* (Honor guild? Poach guild? Economy tavern? The builds diverge here.)

### Act IV — "Storms and Stakes" (Hours 18–30) · Rep: Respected → Renowned
**Player state:** 10–14 heroes, first legendary chase begins, roster specialization visible.
**What unlocks:** Stormreach ~h18 (volatility + daily weather = daily board-check habit), Deadly Contracts ~h20 (the game's biggest opt-in gamble, wrapped in heavy warning flavor — "the notary requires a signature in red ink"), Storm Mage recruitable (forcing the open-board trade-off for board users), legendary *conditions* revealed ~h22 (Retired Hero's "never failed a contract" record check — some players discover their history disqualifies them, giving records real teeth for the NEXT arc), Masked Duelist face-reveal moment for max-loyalty players (~h25 — designed screenshot moment), first seasonal event window.
**Story beats:** The Rival Poacher attempts YOUR best hero (~h24) in a scripted, hard-but-winnable duel; win or lose, the defense unlocks their prospect appearance later. The guild's old rival (from the letter) is revealed as an endgame antagonist guild.
**Emotional target:** *High stakes chosen freely.* Losses here should always trace to a choice the player made.

### Act V — "The Sunken Marches" (Hours 30–40+) · Rep: Renowned → Legendary
**Player state:** 14+ heroes, at least one legendary signed, tavern fully themed.
**What unlocks:** Marches ~h30 (double-twist quests — no template party works; deep-roster mastery test), legendary personal chains resolve (Retired Hero's return quest, Dragonheir stage 5 ~h38+ as the long-arc capstone), Rival Poacher signable → Head of Security (defense-history reward), Legendary rep tier ~h35 (cosmetic crown for the tavern sign; entry into top-league poach matchmaking for players who want it), antagonist-guild questline finale (h36–40).
**Endgame loops beyond h40:** seasonal regions/heroes, top-league PvP, collection completion (all quirks discovered log), tavern "prestige" remodel, and a New-Guild+ option (restart with one heirloom hero) for arc replayers.
**Emotional target:** *Mastery and legacy.*

---

## 13. NPC Dialogue Evolution (making 40 hours feel alive)

Dialogue is the cheapest content that carries the most attachment. Three systems:

### 13.1 Loyalty-staged voice
Every hero has 4 dialogue registers, swapped by loyalty band. Same events, evolving tone:
- **Stranger (interview):** transactional, guarded. Farmhand: "Pay's pay. What's the job?"
- **Signed (low loyalty):** professional, testing you. "You said the crypt job was easy. It wasn't. Noted."
- **Trusted (mid):** personal texture appears — heroes reference their own quirks and pasts. Mercenary: "Last guild I ran with lied about the odds. You don't. That's worth more than the gold. Barely."
- **Devoted (max):** they talk about the *guild*, not the contract, and reference other heroes by name. Cleric: "The Barbarian asked me to check on you. He worries. Don't tell him I told you."
Rule of thumb: ~8–12 lines per register per hero, plus shared archetype pools. Registers make old heroes feel new without new content.

### 13.2 Memory hooks (small data, big effect)
Store a handful of per-hero flags and reference them later:
- First quest together → callback at tier-up ceremony ("Started with wolves in Thornwood. Look at us now.")
- Survived a Disaster → occasional line by the fire ("I still hear those tunnels sometimes.")
- You told the truth when it cost you → referenced in their max-loyalty scene
- You lied in the interview → their Devoted scene includes forgiving you for it — or, for the Mercenary, there is no Devoted scene, only respect
- Defended them from a poach → "They offered double. I told them where to put it."
Five to eight flags per hero, one line each, is enough to feel like the game *remembers*.

### 13.3 World-stage chatter
Tavern patrons' ambient lines are swapped per Act, reflecting reputation tier and story state:
- Act I: "Never heard of this place." / "Is the stew safe?"
- Act II: "The valley's talking about the crew that cleared the crypt road."
- Act III: patrons gossip about *your* rival players by guild name (pulled from recent poach/defense events — cheap dynamic content with real social weight).
- Act IV: "They say the Storm Mage signs for no one. Yet here she is."
- Act V: travelers claim to have come *because* of the guild's name; the condescending guildmaster from hour two asks — humbly — for a table.
Patron chatter is the reputation system made audible. ~20–30 lines per act, shared across all players, is sufficient.

### 13.4 Interview dialogue depth over time
The recruit interview itself deepens by rarity: commons ask 1 question and 1 honesty check; rares ask 3 questions including one that references your visible record ("I heard you broke a contract in spring. Explain."); legendaries conduct a multi-scene courtship across several sessions (Retired Hero visits three times before ever sitting down). Late-game recruiting *feels* weightier because the conversation literally is.

---

## 14. Build Order (solo-dev reality check)

Ship in slices; each slice is a playable game:
1. **Slice 1 (MVP):** Tavern + queue + interview + Thornwood quests + outcome ladder + **mid-quest raven decisions (§4.5)** + **basic floor tasks: serve/seat + eavesdrop (§8b)** + offline earnings + welcome-back screen. No PvP. Commons + 2 uncommons. (Staff hires arrive in Slice 2 once floor tasks exist to automate.)
2. **Slice 2:** Crypts + Gildport, personal chains, tier-up ceremonies, reputation ladder, cosmetics store v1 (recolors + particles + one set).
3. **Slice 3:** Poaching (tokens, temptation minigame, standing pitch), open board, rares.
4. **Slice 4:** Ironvein + Stormreach, Deadly Contracts, seasonal event framework, legendaries.
5. **Slice 5:** Marches, antagonist questline, prestige/New-Guild+, top-league PvP.

Luau implementation notes for later: heroes/quests/dialogue as data tables (ModuleScripts); quirks as ID'd condition functions; dialogue registers as keyed pools; memory hooks as per-hero flag dictionaries in player data. All procedural systems are table lookups — beginner-feasible.

---
*End of design document.*
