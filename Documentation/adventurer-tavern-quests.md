# Adventurer Tavern — Procedural Quest Content Tables
*Companion to the design doc (§4) and script doc. Every slot table the generator draws from: verbs, subjects, antagonists, locations, twists, and all raven pools.*

---

## 0. The Assembly Model (recap)

A quest = **VERB + SUBJECT + ANTAGONIST + LOCATION + 0–2 TWISTS**, all drawn from the tables below, filtered by region.

- **Difficulty** = region tier + antagonist rank + (1 per twist)
- **Reward** = difficulty × party-gap multiplier (punching up pays)
- **Posting text template:** "{VERB phrase} {SUBJECT} {LOCATION phrase} — {antagonist hint}." Twist text is hidden unless a hint leaks (see §4).
- Marches always rolls 2 twists. Thornwood rolls 0–1. Everywhere else 0–2 weighted toward 1.
- **Personal chains** pin one or more slots to a hero's story (pinned slots marked ⚓ in examples, §6).

---

## 1. VERBS (6)

Each verb defines the quest's shape, which stats it leans on, and which raven types it can fire.

| Verb | Shape | Leans on | Raven types allowed |
|---|---|---|---|
| **RESCUE** | Reach target, extract under pressure | Speed, gear; Cleric synergy | Risk fork, twist reveal, character |
| **ESCORT** | Protect moving target A→B | Defense, party size | Risk fork (route), character |
| **HUNT** | Track and defeat a creature/foe | Combat, gear | Risk fork (lair), character |
| **RETRIEVE** | Get object, get out | Rogue skills, gear | Risk fork (vault), twist reveal |
| **INVESTIGATE** | Uncover what's true | Honesty stat, Rogue/Cleric | Twist reveal (its specialty), character |
| **NEGOTIATE** | Reach agreement without steel | Honesty + gold stats, Minstrel/Noble | Twist reveal, character |

**Posting phrase per verb (fill-ins):**
- RESCUE: "Bring back {subject} from {location} —"
- ESCORT: "See {subject} safely through {location} —"
- HUNT: "Put an end to {antagonist} plaguing {location} —"
- RETRIEVE: "Recover {subject} from {location} —"
- INVESTIGATE: "Learn the truth of {subject} at {location} —"
- NEGOTIATE: "Settle terms over {subject} with {antagonist} —"

---

## 2. REGION TABLES

Format: **Subjects** (what the quest is about), **Antagonists** (rank in brackets — rank feeds difficulty), **Locations** (flavor slot), **Demand hints** (the composition clue shown on the posting).

### 2.1 THORNWOOD (Tier 1 — teaching region, any party works)

**Subjects:** a merchant's daughter · a lost hunting party · the miller's strongbox · a stolen mule train · the harvest tithe · a runaway apprentice · the old ranger's maps · a beekeeper's prize hives · a wandering peddler · the village's festival ale

**Antagonists:** wolves [1] · a petty bandit gang [1] · a black bear [1] · the Bramble Boys (comic highwaymen) [2] · a poacher ring [2] · a swindling "toll collector" [2] · the bandit chief Redcap [3 — regional boss]

**Locations:** the old coach road · Wolfhollow · the mill crossing · the burned watchtower · Thornwood deeps · the shepherd's high meadow

**Demand hints:** "fast legs beat strong arms here" (speed) · "they respect a show of force" (party size) · "a friendly face opens the toll gate" (honesty/minstrel)

### 2.2 THE OLD CRYPTS (Tier 2 — cleric/honesty gate)

**Subjects:** a widow's stolen heirloom · the sexton's missing brother · a saint's finger-bone · the parish burial ledger · a sealed reliquary · grave-goods of the old kings · a cursed wedding ring · the crypt-keeper himself

**Antagonists:** restless shamblers [2] · grave-robber crews [2] · a bone-hoarding ghast [3] · the Whispering Choir (spectral) [3] · a false priest running a relic racket [3] · the Hollow Abbot [4 — regional boss]

**Locations:** the sunken chapel · ossuary row · the flooded catacomb · the leaning mausoleum · the pilgrim stairs

**Demand hints:** "the dead sense deceit — send your honest ones" · "blessed hands steady trembling ones" (cleric) · "torchlight and patience, not steel" (investigate-lean)

### 2.3 GILDPORT (Tier 3 — social region)

**Subjects:** a forged bill of lading · a merchant prince's reputation · the harbormaster's ledger · a shipment of "silk" (it is not silk) · a dockworkers' wage dispute · a rigged auction · a smuggled songbird of impossible value · a marriage contract between rival trading houses · the lighthouse charter

**Antagonists:** the Brine Syndicate [3] · a silver-tongued con artist [3] · corrupt customs officers [3] · the auction house cartel [4] · Madame Coil, information broker [4] · the Gilded Chain's local factor [4–5 — story tie-in]

**Locations:** the fog quays · Coin Alley · the bonded warehouse · the Drowned Lantern taproom · the counting-houses · the harbor chain-tower

**Demand hints:** "bring someone who can read a room — and a ledger" · "coin talks here, but honesty haggles" · "no blades past the chain-tower" (negotiate/investigate only)

### 2.4 IRONVEIN MINES (Tier 4 — gear gate, timed postings)

**Subjects:** a trapped survey crew · the Deepline pay chest · a vein-map worth a fortune · the foreman's canary (long story, big reward) · a shipment of blasting powder · the drowned third shaft's secret · a rival company's claim markers

**Antagonists:** cave-in aftermath (environmental) [3] · tunnel wyrms [4] · a claim-jumper militia [4] · the Pale Delvers (things that mine back) [4] · a rogue foreman and his loyalists [4] · the Undervein Queen [5 — regional boss]

**Locations:** the third shaft · the flooded galleries · the powder store · the ore lift · the echo chambers · the company town of Gritstone

**Demand hints:** "good steel or no deal — the deep eats cheap gear" · "the clock matters more than the roster" (timed) · "small parties fit where large ones die" (party-size cap twist common here)

### 2.5 STORMREACH PEAKS (Tier 5 — volatility, deadly contracts)

**Subjects:** a downed sky-courier · the hermit-sage's final letter · a storm-glass harvest · an avalanche-buried caravan · the monastery's ringing bell (it will not stop) · a dragon's shed scale (the dragon is fine; the collectors are not) · the weather-station's last reading

**Antagonists:** storm elementals [4] · the Thunderbound cult [4] · a mad hermit and his "congregation" of statues [5] · harpy wing-clans [5] · the avalanche itself (environmental) [5] · the Storm-Tyrant's brood [6 — regional boss/deadly tier]

**Locations:** the shattered stair · Galehold monastery · the glass fields · the roost cliffs · the last weather station · the Storm-Tyrant's shadow

**Demand hints:** "check the sky before the roster" (daily weather modifier) · "volatile ground — outcomes swing wide here" · "RED SEAL: deadly contract terms apply"

### 2.6 THE SUNKEN MARCHES (Tier 6 — endgame, always 2 twists)

**Subjects:** the drowned city's bell-crown · a scholar who went looking and stopped writing · the black barge and its silent crew · seeds from the garden that predates gardens · the treaty stone of a kingdom no map shows · your uncle's last waypoint ⚓ (story) · the Gilded Chain's expedition (story)

**Antagonists:** the Mire-Sworn [5] · leech-priests of the Old Water [5] · the Unremembered (they take names) [6] · bog-iron revenants [6] · the March-Warden, neither living nor local [6] · That Which the Marsh Keeps [7 — final boss tier]

**Locations:** the causeway of teeth · the half-sunk library · the lantern shallows · the garden that predates gardens · the black barge moorings · the deep sink

**Demand hints:** "no single answer survives the Marches — bring range" · "two things will go wrong; plan for the third" · "names are currency here; spend carefully" (Unremembered twist warning)

---

## 3. TWISTS

Each twist: mechanical effect · favored heroes/stats · whether it can leak a **hint** on the posting (H) or only surface via **reveal raven** (R).

### 3.1 Global twists (any region)

| Twist | Effect | Favors | Leak |
|---|---|---|---|
| **The target lies** | Subject/client is deceiving; honesty check mid-quest decides branch | Honesty heroes, Investigate | R |
| **Cursed ground** | Injury severity +1 band without cleansing | Cleric, Witch | H |
| **Collapsing/unstable** | Speed beats strength; slow parties auto-Setback risk | Rogue, light parties | H |
| **Double bounty** | Second objective appears; taking it raises band both ways | Gamblers | R |
| **Rival crew on-site** | Another guild's NPC party races you; win = Triumph chance up | Speed, Duelist | H |
| **The witness** | Someone sees everything; how you act feeds reputation ±2 | Honor builds | R |
| **Night work** | Quest extends past dark; new antagonist sub-table activates | Rogue, Mage | H |
| **Weeping client** | Client emotionally attached to outcome; Setback also costs rep | Cleric, Minstrel | H |
| **It's a trap** | The posting itself is bait; party must extract | Defense, Duelist | R |
| **Old debt** | Antagonist recognizes a party member (personal-chain hook) | pinned hero | R |

### 3.2 Region-flavored twists

| Region | Twist | Effect | Leak |
|---|---|---|---|
| Thornwood | **Festival traffic** | Roads crowded; Escort +time, but witnesses everywhere (rep swing) | H |
| Thornwood | **The "bandits" are farmers** | Desperate locals; fight (fast, rep down) or negotiate (slow, rep up) | R |
| Crypts | **The relic resists** | Cursed object fights removal; Cleric halves the penalty | H |
| Crypts | **False priest's flock** | Civilians in the way; violence auto-drops one band | R |
| Gildport | **Paper trail** | Evidence must survive; Rogue protects it, brawlers risk it | H |
| Gildport | **Everyone's bribeable** | Gold can skip a stage — at an honesty ding | R |
| Ironvein | **Bad air** | Party stamina drains; small parties or Witch potions favored | H |
| Ironvein | **Company politics** | Two clients claim the same contract; pick a side (rep/gold fork) | R |
| Stormreach | **Weather lock** | Storm severity re-rolled mid-quest; Mage can steer | H |
| Stormreach | **Altitude** | Gear quality checked twice | H |
| Marches | **Names taken** | A hero's "name" is held; retrieving it is a bonus objective | R |
| Marches | **The ground remembers** | Past guild actions (record!) literally shape encounters | R |

---

## 4. RAVEN POOLS (complete)

Every raven: trigger condition · message text (slots in {braces}) · options with mechanical outcomes · auto-resolution if the timer expires. Target cadence: 1–3 ravens per quest; never two of the same type back-to-back.

### 4.1 RISK FORKS (per verb)

**RESCUE**
1. "The guards rotate at the hour. {Leader} can rush now — loud, fast — or wait for the gap. Word?"
   - Rush → −time, band swings wider both ways
   - Wait → +time, steady odds
   - *Expired:* "No word. {Leader} waited for the gap." (safe path)
2. "{Subject} isn't alone — two other captives beg to come. More to carry, more to feed, more to save."
   - Take all → +rep, −speed, Setback risk up
   - Contract only → neutral, small rep ding if The Witness is active
   - *Expired:* contract only.
3. "The back way is flooded to the waist. Shortcut through cold water, or the long dry road past the watch?"
   - Water → −time, minor injury risk
   - Road → +time, detection risk
   - *Expired:* road.

**ESCORT**
4. "The pass ahead is faster; the valley road is safer. {Subject} says they're 'not in a hurry.' {Subject} is lying — check the contract date."
   - Pass → −time, ambush risk up
   - Valley → +time, safe; timed postings may expire
   - *Expired:* valley.
5. "Push through the night to arrive early, or camp? {Leader} notes the party's tired. {Leader} is also tired of {Subject}'s singing."
   - Push → Triumph pace, fatigue (next quest −1 readiness)
   - Camp → normal
   - *Expired:* camp.
6. "A second caravan begs to join yours for protection. Bigger target, bigger thanks."
   - Accept → +rep +gold, antagonist rank effectively +1
   - Decline → neutral
   - *Expired:* decline.

**HUNT**
7. "Tracks split. The old sire went left — bigger bounty, worse odds. The young ones went right."
   - Sire → band up both ways, +reward
   - Young → contract-standard
   - *Expired:* young.
8. "The lair has a back entrance. Smoke them out toward the party (clean, slow) or go in (fast, dark, personal)?"
   - Smoke → +time, safe
   - Go in → −time, injury risk
   - *Expired:* smoke.
9. "The beast is denned with cubs. The contract says 'end the threat.' {Leader} awaits interpretation."
   - Full clearance → +gold, rep ding, Cleric/Witch loyalty ding if present
   - Drive them off → −gold, +rep, Witch loyalty tick
   - *Expired:* drive off.

**RETRIEVE**
10. "{Rogue if present: 'Vex found' / else: 'The party found'} a side way into the vault. Off the plan entirely."
    - Side way → Triumph chance up, small Disaster chance appears
    - Stick to plan → neutral
    - *Expired:* plan.
11. "The object's twin sits beside it. Taking both isn't stealing if it's already stealing, argues {greediest member}."
    - Both → +loot, honesty ding, Old Debt twist chance next quest
    - One → neutral, Noble/Cleric approval tick
    - *Expired:* one.
12. "Alarm tripped — not by ours. Someone else is robbing the place TONIGHT. Race them, or let them draw the guards?"
    - Race → speed check, Triumph/Setback swing
    - Let them → +time, safe, they may take a bonus item
    - *Expired:* let them.

**INVESTIGATE**
13. "Two witnesses, one hour. The frightened maid knows more; the smug clerk lies better. Who first?"
    - Maid → truth path (honesty stat)
    - Clerk → paper path (Rogue)
    - *Expired:* maid.
14. "The truth is in the cellar ledger — behind a lock. Pick it (quiet, illegal) or subpoena it (loud, legal, slow)?"
    - Pick → −time, honesty ding
    - Subpoena → +time, +rep
    - *Expired:* subpoena.

**NEGOTIATE**
15. "{Antagonist} offers to settle early — at two-thirds terms. The full deal needs one more day at the table."
    - Take it → −time, −gold
    - Hold out → +time, full gold, small collapse risk
    - *Expired:* take it.
16. "Their negotiator is drunk and friendly. Press the advantage now, or adjourn like honorable folk?"
    - Press → +gold, honesty ding, Witness twist punishes it
    - Adjourn → +rep, Noble loyalty tick
    - *Expired:* adjourn.

### 4.2 TWIST REVEAL RAVENS (one per twist that reveals mid-quest)

- **The target lies:** "The ransom note is a lie — the 'captive' is in on it. Spring the trap on THEM, or walk away with the fee and the secret?"
  - Spring → +rep +reward band, combat risk
  - Walk → fee kept, no bonus, client never knows
  - *Expired:* walk.
- **Double bounty:** "A second mark just surfaced — the contract's brother, twice the trouble, twice the purse. In or out?"
  - In → both bands widen, +reward
  - Out → standard
  - *Expired:* out.
- **Rival crew (if not leaked):** "Another guild's crew is already inside — {RivalGuildName}'s colors. Race, cooperate, or shadow them?"
  - Race → speed swing · Cooperate → split reward, +rep · Shadow → they take the risk, you take leavings
  - *Expired:* shadow.
- **The witness:** "A chronicler has been following the party for two days, writing EVERYTHING. Play to the page, ignore, or pay for the pen?"
  - Play → rep swing doubles both ways · Ignore → honest neutral · Pay → rep protected, honesty ding, gold cost
  - *Expired:* ignore.
- **It's a trap:** "It's a trap — the posting was bait and the door just barred. {Duelist if present: 'The Feather is smiling.' } Fight through, or find the poster's real game first?"
  - Fight → combat band · Investigate-in-place → slower, converts to INVESTIGATE verb rewards
  - *Expired:* fight.
- **Old debt:** "{Pinned hero} stopped cold. They KNOW this one. 'Let me handle it alone' — or keep the party together?"
  - Alone → personal-chain scene, band swing on their skill `{chain_flag}`
  - Together → safe, chain progresses slower
  - *Expired:* together.
- **The "bandits" are farmers:** "They're not bandits. They're farmers with borrowed swords and empty larders. The contract says clear the road."
  - Fight → fast, −rep, Cleric ding · Negotiate → slow, +rep, may cost gold · Pay them yourself → gold down, rep UP, secret Minstrel ballad unlock
  - *Expired:* negotiate.
- **Everyone's bribeable (Gildport):** "The clerk will 'lose' the file for a price. The price is reasonable. The precedent is not."
  - Pay → skip a stage, honesty ding · Refuse → full path, Noble tick
  - *Expired:* refuse.
- **Company politics (Ironvein):** "Two foremen, one contract, both claiming to be the client. Pick your paymaster."
  - Side A (rich) → +gold · Side B (right) → +rep · Play both → gold AND a future It's-a-trap seed
  - *Expired:* side B.
- **Names taken (Marches):** "The Unremembered took {member}'s name mid-march. They answer to nothing now. Retrieve it — a detour into the deep sink — or finish first and hope it keeps?"
  - Retrieve → +time, deep-sink encounter, guaranteed memory-hook scene after
  - Finish first → member fights at −1 until next rest
  - *Expired:* finish first.
- **The ground remembers (Marches):** "The marsh is replaying the guild's record. {If record clean: 'The path firms underfoot.' / If broken contracts: 'Something wearing an old client's face walks alongside.'}" *(no choice — a record-driven modifier announced dramatically)*

### 4.3 CHARACTER-MOMENT RAVENS (trigger table)

Per-hero raven scripts live in the script document. This table is the generator's trigger logic — when each may fire:

| Hero | Trigger condition | Raven (see script doc) |
|---|---|---|
| Bram | Party confidence low OR shielding event | "sure about this one" / "don't make it weird" |
| Perrin | NEGOTIATE verb OR bored-guards state | "deploy the funny song" |
| Vex | RETRIEVE verb, vault stage | "side door — trust me or don't" |
| Maren | Cursed ground twist active | "cleanse or push through" |
| Grunwald | Fear-tagged antagonist (undead, dark, spiders) | "frozen at the cave mouth" |
| Alduin | NEGOTIATE verb OR parley offer state | "parley over dinner" |
| Korr | Client-lies state (target-lies twist or Gildport) | "confront or finish first" |
| Nettle | Herb-rich location OR injured party | "brew mid-quest" |
| Vane | Gildport/noble antagonist | "leverage the history" |
| Brokka | Sealed/bonus loot object present | "finders keepers is BASICALLY law" |
| Feather | Champion-type antagonist | "single combat" |
| Iriseth | Weather-lock twist OR Stormreach | "steer the storm" |
| Aldric | Legendary-tag antagonist | "end it alone or teach" |
| Ember | Stage 3+, any combat spike | "lean in or hold" |
| Sable | Defense context only (not quests) | — |

**Generator rules:** max one character raven per quest per hero; character ravens take priority over generic ones when triggers overlap; a hero's raven never fires twice in a row across quests (freshness rule).

### 4.4 NEUTRAL AUTO-RESOLUTIONS (expired ravens, shared)

- "No word came, so {leader} chose the cautious road. The party continues."
- "The moment passed. {Leader} shrugged and kept to the plan."
- "The ravens found the window shut. {Leader} made the safe call and grumbled about it."

---

## 5. QUEST-GIVER FLAVOR SLOTS (who posts the job)

Rotates on the board posting; purely flavor, but Weeping-client twist upgrades it to mechanics.

farmer's collective · a nervous clerk with a seal he clearly borrowed · the harbormaster's office · an anonymous red-wax letter · a child with exact coins and no explanation · the monastery · a rival guild (swallow your pride, take their gold) · the town council, 4–3 vote attached · "a friend of the hall" (rep-gated, pays double) · the Gilded Chain (story quests, Acts IV–V)

---

## 6. ASSEMBLY EXAMPLES (sanity checks)

1. Thornwood, T1: ESCORT + the festival ale + the Bramble Boys [2] + old coach road + Festival traffic (H)
   → "See the festival ale safely through the old coach road — the Bramble Boys are thirsty, and the whole valley's watching."
   → Difficulty 1+2+1=4. Ravens: #5 (push/camp), festival = witnesses modifier.

2. Crypts, T2: INVESTIGATE + the parish burial ledger + false priest [3] + sunken chapel + The target lies (R)
   → "Learn the truth of the burial ledger at the sunken chapel — Father Ostwin fears his own curate."
   → Difficulty 2+3+1=6. Ravens: #13 (maid/clerk), then target-lies reveal.

3. Marches, T6 (2 twists): RETRIEVE + the bell-crown + the Unremembered [6] + half-sunk library + Names taken (R) + Cursed ground (H)
   → "Recover the bell-crown from the half-sunk library — the ground is old and unquiet, and what waits there does not fight fair. RED-ADJACENT: bring your best."
   → Difficulty 6+6+2=14. Ravens: #10 (side way), names-taken reveal, Maren's cleanse (cursed ground trigger).

4. Personal chain (Feather ⚓): HUNT + ⚓"the Duelist's old rival" [rank=Feather's tier] + roost cliffs + Old debt (R, ⚓auto)
   → Fires Feather's single-combat raven AND the old-debt "let me handle it alone" scene — chain quests stack character content deliberately.

---

## 7. CONTENT COUNTS & EXPANSION RULE

Shipped in this document: 6 verbs · 47 subjects · 39 antagonists · 34 locations · 22 twists · 16 risk-fork ravens · 11 twist-reveal ravens · 15 character triggers · 10 quest-givers.
Raw combinations comfortably exceed the 40-hour arc's needs; repetition is felt at the TWIST layer first — when players start predicting twists, add 4–6 new twists before anything else. Subjects are the cheapest slot to expand (one line each); antagonists the most expensive (each needs encounter logic). Personal-chain pins are the highest-value additions per line written.

*End of quest content tables.*
