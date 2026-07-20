# Adventurer Tavern — Master Script Document
*Companion to the design doc. All scripted (deterministic) dialogue: interviews, loyalty registers, quirk lines, raven decisions, quest returns, poach defenses, tier-ups, memory hooks, patrons, staff, and story NPCs.*

---

## 0. Conventions

- `[P]` = player choice. `→` = consequence/branch. `{flag}` = memory hook stored or fired.
- **Honesty checks** in interviews: the truthful option is always the *less flattering* one. Lying is never blocked — it works now, costs later.
- **Loyalty registers:** STRANGER (interview) → SIGNED (low) → TRUSTED (mid) → DEVOTED (max). Lines listed per register are pools; the game picks randomly within the current register.
- **Raven decisions** are written per-hero for "character moment" events; risk-fork and twist-reveal ravens use the shared pools in §7.
- Lines are written for text display; keep each under ~120 characters where possible for mobile bubbles.

---

## 1. Interview Framework (all heroes)

**Shared skeleton — every interview walks these beats; per-hero content below overrides the generic lines:**

1. **Approach.** Hero is seated; player walks up. Hero opens with their VOICE line (per-hero).
2. **Their question(s).** Common: 1 question. Uncommon: 2. Rare: 3 (one references your public record). Legendary: multi-scene courtship (see each legendary).
3. **The honesty check.** At least one question where the truthful answer is unflattering. Branches:
   - Truth → hero notes it. `{told_truth}` → referenced in their TRUSTED/DEVOTED scenes.
   - Lie → hero appears satisfied → signs SUSPICIOUS (loyalty starts lower). `{lied_interview}` → surfaces later per-hero.
4. **Your questions.** Player may ask up to 2 (rare+: 3): "What do you want?" (reveals 1 preference), "Where have you worked?" (flavor + 1 pref hint), "Anything I should know?" (quirk HINT, never the quirk itself).
5. **The ask.** Hero states terms. Player: Sign / Negotiate (one counter allowed) / Let them think (returns to queue timer).

**Generic fallback lines (used if a per-hero line is missing):**
- Approach: "You the one who runs this place?"
- Truth response: "Huh. Most owners dress it up. I'll remember you didn't."
- Lie-discovered later: "Funny. That's not how you told it when I sat at your bar."
- Sign: "Then we have terms. Where do I put my boots?"
- Walk away: "Maybe another season. Keep the fire lit."

---

## 2. COMMON HEROES

### 2.1 Farmhand Fighter — "Bram"
*Voice: plain, earnest, understatement. Never uses two words where one does.*

**INTERVIEW**
- Approach: "Heard there's coin here for a man with a strong back. That true, or just talk?"
- His question: "Pay's steady?" 
  - [P] "Steady as I can make it." → "Good enough."
  - [P] "Best pay in the valley!" (if false) → LIE. Signs anyway. `{lied_interview}`
- Honesty check: "Place looks... lived-in. Business good?"
  - [P] Truth ("It's a mess, honestly.") → "Mess I can fix. Lies I can't." `{told_truth}`
  - [P] Puff ("Booming.") → "...Right." Signs SUSPICIOUS.
- Quirk hint (if asked "Anything I should know?"): "I work better on a full stomach. Just saying."
- Sign: "Alright, boss. Point me at something."

**SIGNED (low loyalty)**
- "Job's a job."
- "You feed your people here, or is that extra?"
- "Wolves again? Fine. Wolves it is."

**TRUSTED (mid)**
- "My da worked a field thirty years for less thanks than you give in a week."
- "Stew's good tonight. Don't tell the cook I said."
- (if `{told_truth}`) "You know what I liked? First day, you said the place was a mess. It was. You didn't pretend."

**DEVOTED (max)**
- "This is the first place felt like mine since the farm."
- "The new ones ask me what you're like. I tell 'em: fair. That's the whole review."
- (if `{lied_interview}`) "You stretched the truth when I signed. I knew. Signed anyway. Don't do it again, yeah?"

**QUIRK LINES (stew served → loyalty tick)**
- On serve: "Now THAT'S a proper bowl. Alright. ALRIGHT. Let's work."
- Hint if unfed 2 sessions: "Kitchen cold again? A man notices."

**RAVEN — character moments**
- (low confidence event) "Bram's asking if you're sure about this one, boss. He'll go if you say go."
  - [P] "Go." → +risk, +Bram XP on success
  - [P] "Pull back." → safe, small loyalty tick ("You called us home. Noted.")
- (with Cleric in party) "Bram took a hit shielding the Cleric. He says don't make it weird."

**QUEST RETURNS**
- Triumph: "Went well. Don't ask me to say more than that."
- Success: "Done. What's next?"
- Setback (limping): "Worth it, boss." *(hour-one anchor line — always this, first time)* `{first_setback}`
- Disaster: "...Give me a day. Maybe two. Then we talk about what went wrong."

**POACH DEFENSE (standing pitch context)**
- Auto-defense flavor: "Double the coin? Coin spends anywhere. This place feeds me. Walk on."
- If defended by player live: "You came down for that? Huh. Boss came down for that."

**TIER-UPS**
- → Sword Fighter: "A real sword. Da would've laughed. Then he'd have cried a bit. Same as me, don't look."
- → Militia Captain: "Me. Teaching. If you'd told the wolves-job me... {first_setback: 'Still worth it, boss.'}"

**MEMORY HOOKS**
- {first_setback} at final tier-up: "Started with wolves in Thornwood. Look at us now."
- After any Disaster survived: "I still dream about that job sometimes. We don't send greens on those. Promise me."

---

### 2.2 Wandering Minstrel — "Perrin"
*Voice: theatrical, self-deprecating, allergic to silence.*

**INTERVIEW**
- Approach: "Ah! An audience of one! My favorite size — statistically my only size."
- His question: "Be honest — do people *laugh* here, or merely drink until they think they do?"
- Honesty check: "Will I be paid in coin, or in 'exposure'? I've been paid in exposure. I nearly died of it. Twice."
  - [P] Truth ("Coin's thin right now.") → "Thin coin, honestly offered, is a ballad. Fat coin, falsely promised, is a dirge. I accept." `{told_truth}`
  - [P] Lie ("You'll be rich.") → "Marvelous! I shall hold you to that in the most public and musical way possible." SUSPICIOUS. `{lied_interview}`
- Quirk hint: "A minstrel without a stage is just a man complaining in rhythm."
- Sign: "Then strike up the — well. Me. Strike up me."

**SIGNED** 
- "No stage yet, I see. I shall sing to the soup. The soup, at least, listens."
- "Request line is open. Refusals also open."

**TRUSTED**
- "I wrote a verse about you. It's mostly flattering. The rhyme scheme forced one insult."
- "You know why I sing for honest folk? Liars always want a different song than the one that's true."

**DEVOTED**
- "Every tavern has a sound. Yours is the good kind of loud. I'd know — I've been thrown out of the other kind."
- "When I go — years from now, dramatically, mid-song — put the lute over the fire. It'll want to stay."

**QUIRK LINES (stage/music decor)**
- Stage built: "A STAGE. A real —  everyone SHUT UP, I mean, gather round!"
- No stage, 3+ sessions: "I performed in the corner today. The corner. My mother was right about everything."

**RAVEN — character moments**
- (negotiation quest) "Perrin says the guards look bored. Permission to 'deploy the funny song'? Consequences unknowable."
  - [P] Deploy → high variance: Triumph or Setback
  - [P] Deny → neutral ("A tragedy. It was VERY funny.")

**QUEST RETURNS**
- Triumph: "They wept! With joy! Mostly joy! Definitely more than half joy!"
- Success: "A competent performance. Ugh. 'Competent.' Don't put that on my poster."
- Setback: "The crowd turned. Crowds do that. Like weather, or geese."
- Disaster: "...I don't want to sing about this one. That's how you'll know it was bad."

**POACH DEFENSE**
- "They offered a bigger stage. But the *acoustics* of loyalty, friend — unmatched. Shoo."

**TIER-UPS**
- → Bard: "'Bard' — official! Legally I may now be insufferable in THREE more counties."
- → Songweaver: "They say a Songweaver's songs bring coin through the door. Watch the till, boss. Watch it dance."

**MEMORY HOOKS**
- {told_truth}: (Devoted scene) "My best song is still the one about the owner who said 'coin's thin' with a straight face. Honesty in E minor. Beautiful."

---

### 2.3 Street Rogue — "Vex"
*Voice: clipped, wary, exits conversations early. Trusts actions only.*

**INTERVIEW**
- Approach: "Saw your board. Saw your locks. The locks are bad. Talk fast."
- Her questions: "Who else knows I'm here?" / "You keep books on your people?"
- Honesty check: "This guild clean? And think before you answer, because 'yes' is the wrong answer. Nobody's clean."
  - [P] Truth ("We've cut corners.") → "Good. Clean guilds lie the biggest." `{told_truth}`
  - [P] "Spotless." → Eyes narrow. SUSPICIOUS. "Sure it is." `{lied_interview}`
- Quirk hint: "Crowds are how you get remembered. I don't do remembered."
- Sign: "Fine. I'm not shaking hands. It's nothing personal. It's fully personal."

**SIGNED**
- "Don't put my name on the board. Initials. One initial."
- "Your back door sticks. Fixed it. You're welcome. Don't ask why I checked."

**TRUSTED**
- "Fixed your locks. All of them. Slept better after. That's — whatever. Forget it."
- "You want to know about rival taverns, ask. Knowing things is the one thing I'm generous with."

**DEVOTED**
- "I've walked out on every crew I ever ran with. You'll notice I'm still here. Notice quietly."
- "If anyone asks, I don't like this place. If anyone touches this place, they'll learn different."

**QUIRK LINES (queue > 3 = won't sign / loyalty friction)**
- (as prospect, queue full): "Too many faces in here tonight. I'll find you when it's quieter." *(leaves — quirk teaching moment)*
- (signed, crowded): "Busy night. I'll be on the roof. Yes, we have a roof. No, I'm not telling you how I get up there."

**RAVEN — character moments**
- "Vex found a side door into the vault. Off the plan. Her words: 'trust me or don't.'"
  - [P] Trust her → big Triumph chance, small Disaster chance
  - [P] Stick to plan → neutral ("Your call. The boring call, but yours.")

**QUEST RETURNS**
- Triumph: "In. Out. Nobody saw. That's a good day."
- Success: "Done. One of them saw my face. Handled it. Don't ask."
- Setback: "It went loud. I hate loud."
- Disaster: "Someone talked. Wasn't me. I'll find who."

**POACH DEFENSE**
- "Recruiting me in my own bar. Bold. Stupid, but bold. Door's behind you."

**TIER-UPS**
- → Burglar: "Promotion, huh. Don't announce it. Seriously. If you throw a party I will climb out the window."
- → Shadow Agent: "New job title. Now I watch THEIR taverns. This is the best day of my — this is fine. It's fine."

**MEMORY HOOKS**
- {told_truth}: "You said 'we've cut corners' the day we met. Most honest thing an owner ever told me. Still true?"
- After she's defended from poach: "You didn't sell me out for the counter-offer. Filed that away. Big file."

---

### 2.4 Village Cleric — "Sister Maren"
*Voice: warm, unhurried, gently immovable. Says hard things kindly.*

**INTERVIEW**
- Approach: "Peace on this house. I heard there are people here who get hurt. That's usually where I'm needed."
- Her questions: "Do your people come home?" / (sees injured hero, if any) "Who tends to that one?"
- Honesty check / bribe refusal: If player offers extra gold: "Put it away, friend. Gold doesn't sway me — it just tells me you think it should."
  - [P] Truthful answer to "Do your people come home?" ("Not always whole.") → "Then we'll mend them together." `{told_truth}`
  - [P] "Always, no exceptions." → A long, kind look. "We both know better. But I hear the wish inside the lie." SUSPICIOUS (gentlest version). `{lied_interview}`
- Quirk hint: "Idle hands trouble me. Wounded ones, oddly, give me purpose."
- Sign: "Then I'll fetch my things. Keep the kettle on — healing is nine parts tea."

**SIGNED**
- "Your medicine shelf is a superstition and a prayer. We'll fix that."
- "Tell the fighters: pain hidden is pain doubled."

**TRUSTED**
- "The Barbarian pretends his armor squeaks so he has an excuse to visit me. I oil it slowly."
- "You carry this place on your back, you know. Even owners need tending."

**DEVOTED**
- "The Barbarian asked me to check on you. He worries. Don't tell him I told you."
- "I've served chapels colder than your tavern hearth. I know which one felt more like faith."

**QUIRK LINES (injured guildmate → loyalty rises)**
- Hero returns hurt: "Bring them to me. — No, it's alright. Truly. This is the part I'm *for*."

**RAVEN — character moments**
- (cursed ground) "Sister Maren says the ground here is wrong. She can cleanse it — slow — or ward the party and push through — fast."
  - [P] Cleanse → longer quest, removes twist
  - [P] Push through → normal speed, twist stays

**QUEST RETURNS**
- Triumph: "Not one scratch to mend. I confess I feel slightly unemployed. It's wonderful."
- Success: "All home. Bruises only. Bruises I can love."
- Setback: "They'll heal. Sit with them tonight, though. That part's your medicine to give, not mine."
- Disaster: "I need bandages, boiled water, and for you to not blame yourself louder than I can work. Go."

**POACH DEFENSE**
- "You'd hire away a healer from her wounded? Then you've told me everything about your guild I need."

**TIER-UPS**
- → Priest: "A priest's blessing carries further, they say. We'll test the range together."
- → High Cleric: "High Cleric. Hm. The title fits strangely — like new boots. The work, though — the work fits perfectly."

**MEMORY HOOKS**
- {lied_interview}: (Devoted) "That kind lie you told me the first day — 'always, no exceptions.' You've spent every day since trying to make it true. That's better than honesty. That's penance."

---

## 3. UNCOMMON HEROES

### 3.1 Cowardly Barbarian — "Grunwald the (Eventually) Brave"
*Voice: enormous man, small voice. Comically specific fears. The tavern's heart.*

**INTERVIEW**
- Approach: "I— hello. I'm told I look intimidating. Please don't be intimidated. It's mostly shoulders."
- His questions: "How thick is your armor? The armor you give people. Numerically." / "Rate your spiders. Tavern spiders. One to ten."
- Honesty check: "Do your quests have... surprises? I don't love surprises. Surprises are just ambushes with better publicity."
  - [P] Truth ("Sometimes it goes wrong.") → "...Okay. Okay okay okay. But you TELL people when it might. That's all I ask. Warnings." `{told_truth}`
  - [P] "Never! Totally safe!" → "REALLY? Wonderful! ...Really?" SUSPICIOUS (anxious version). `{lied_interview}`
- Quirk hint: "Good armor is a hug you can wear into a fight."
- Sign: "I'll do it. I'll — yes. Signing. Look at me signing. Very brave already."

**SIGNED**
- "I checked the cellar for monsters. None. I'll check again tomorrow. Vigilance."
- "Is the big sword mandatory, or can I hold a medium sword with big confidence?"

**TRUSTED**
- "Sister Maren oils my armor when it squeaks. Don't tell her I loosen it on purpose."
- "You know what's braver than not being scared? Going anyway. I read that on a tapestry. Gripping tapestry."

**DEVOTED**
- "I'm still scared. Every job. But now it's — smaller than the other thing. The us thing. Team. I mean team."
- "If anything ever comes for this tavern, it will have to go through me. It WILL get through me, but SLOWLY."

**QUIRK LINES (flees temptation events)**
- Poach attempt on him: "A stranger wants to talk to me privately about my FUTURE? Absolutely not. Goodbye. GOODBYE." *(auto-defends by fleeing)*

**RAVEN — character moments**
- "Grunwald's frozen at the cave mouth. Cleric can talk him through it, or you can send word: 'come home, no shame.'"
  - [P] Talk him through → quest continues, +courage arc progress `{cave_moment}`
  - [P] Call him home → safe, his arc pauses, loyalty tick ("You said no shame. There wasn't any. There WAS relief.")

**QUEST RETURNS**
- Triumph: "I did a BRAVERY. An accidental one, but it COUNTS."
- Success: "Nobody died and I only screamed tactically."
- Setback: "The bandits were... taller than advertised. Boss, we need to talk about the advertising."
- Disaster: "...I ran. I got them out, but I ran first. Sister Maren says that's the same thing as brave. Is it? Don't answer fast."

**TIER-UPS**
- → Reluctant Barbarian: "'Reluctant.' An upgrade from 'Nervous.' The bards will sing of my mild improvement!"
- → Reckless Barbarian: *(after {cave_moment})* "Remember the cave? I go FIRST now. WHO IS THIS MAN. It's me. It's still me, just — forward."

**MEMORY HOOKS**
- {cave_moment} referenced at final tier: "You didn't leave me at that cave. So I stopped leaving me there too."

---

### 3.2 Gourmet Knight — "Sir Alduin of the Laden Table"
*Voice: grand chivalric diction applied entirely to food.*

**INTERVIEW**
- Approach: "I have ridden far, and I smell... rosemary? A house of culture. Proceed."
- His questions: "Your guild's honor — unstained?" / "Your bread — and think carefully — crusty or soft?"
- Honesty check: "Has this guild ever broken its sworn word?" *(reads your public record — answer is checkable)*
  - [P] Truth matching record → "So the ledger says, and so say you. Alignment! The rarest seasoning." `{told_truth}`
  - [P] Lie against record → "Odd. The ledgers sing a different recipe." SUSPICIOUS. `{lied_interview}`
- Quirk hint: "An army marches on its stomach. A knight *gallops* on his."
- Sign: "My sword, my honor, and my appetite — all three are yours. Feed at least two."

**SIGNED**
- "The stew is honest work. Honest work with insufficient thyme."
- "I patrol the kitchen nightly. For security. Security reasons."

**TRUSTED**
- "In the siege of Marrowgate I ate my own boot. Braised, mind you. Standards even in despair."
- "Your table is becoming known in three counties. I may have... evangelized."

**DEVOTED**
- "Many halls have offered me feasts. Only this one offered me a *seat that was mine.* The distinction is everything."
- "When I first came, I stayed for the bread. I remain for the baker. All of you. You're all the baker. You understand."

**QUIRK LINES (kitchen upgrades count double)**
- Kitchen upgraded: "A NEW OVEN. Sound the horns. Sound them DELICIOUSLY."

**RAVEN — character moments**
- "Sir Alduin reports the bandit chief has offered parley... over dinner. He requests permission to negotiate. And attend. Mostly attend."
  - [P] Parley → negotiation path (honesty stats shine)
  - [P] Refuse → combat path ("He fights better hungry anyway. Angrier.")

**QUEST RETURNS**
- Triumph: "Victory! And the roadside inn en route — magnificent. Two triumphs, honestly."
- Success: "The quest is done and the rations were adequate. I have notes. Seventeen notes."
- Setback: "We were ambushed at luncheon. LUNCHEON. Some men have no code whatsoever."
- Disaster: "I have no appetite tonight. ...Yes. It was that bad."

**POACH DEFENSE**
- "Your master's table may groan with gold — but does his cook know my name? Mine does. Good day."

**TIER-UPS**
- → Feast Knight: "Feast Knight! At last, a title one can pronounce while chewing."
- → Paladin of Plenty: "They say my presence now draws diners to the hall. A holy calling. The HOLIEST calling."

---

### 3.3 Grizzled Mercenary — "Korr"
*Voice: transactional, weathered, dry. Respect is his only currency besides gold.*

**INTERVIEW**
- Approach: "I cost what I cost. Ask your questions, I'll ask mine, we'll see."
- His questions: "Rate of pay?" / "Last guild that broke a contract with you — what happened to them?"
- Honesty check: "Ever shorted a hero's pay? Careful. I check. I always check."
  - [P] Truth → "Everyone has. You said it plain. That buys you exactly one chance." `{told_truth}`
  - [P] Lie (against record) → *(he checks)* → does not sign. Leaves: "You had one job in this chat." *(returns to queue pool much later — the game's hardest interview)*
- Quirk hint: "I don't care how you treat me. I watch how you treat the ones who cost less."
- Sign: "Contract. Ink. Now. Words are wind."

**SIGNED**
- "Pay cleared. So far, so professional."
- "Don't confuse me being here with me liking it here. ...Yet."

**TRUSTED**
- "Last guild I ran with lied about the odds. You don't. That's worth more than the gold. Barely."
- "The farm kid — Bram — he's got it. Whatever it is. Don't waste him on wolf work forever."

**DEVOTED** *(Korr has no soft register — his Devoted is respect, not warmth)*
- "Twenty years of contracts. This is the first one I stopped counting the days on."
- "You want my honest assessment of this guild? I'm still in it. End of assessment."

**QUIRK LINES (walks if ANY hero's contract is broken)**
- Warning (another hero shorted): "I heard what happened with the kid's pay. Fix it by sundown or my boots fix it for me."
- Departure (if unfixed): "Told you I check. Contract's void. All of them are, now — you just don't know it yet." *(leaves permanently)*

**RAVEN — character moments**
- "Korr says the client's lying about the cargo. He can confront now — messy — or finish the job and renegotiate after, from strength."
  - [P] Confront → honesty path, reputation up, gold down
  - [P] Finish first → gold up, small honesty ding

**QUEST RETURNS**
- Triumph: "Clean work. Bonus was earned. Emphasis: earned."
- Success: "Done. Invoice is on your desk. It itemizes."
- Setback: "Client lied about the numbers. They always lie about the numbers. Adjusted invoice on your desk."
- Disaster: "We got out. Debrief tomorrow. Tonight I drink alone, and that's not sad, it's SCHEDULED."

**POACH DEFENSE**
- "Triple pay? Show me the contract. ...Mm. Clause nine's a trapdoor. Amateurs. I work for people who don't need trapdoors."

**TIER-UPS**
- → Veteran: "Same me, higher rate. Congratulations on affording it."
- → Warmaster: "Two jobs at once now. Don't smile. It's a workload, not a friendship."

**MEMORY HOOKS**
- {told_truth}: "Day one, you admitted you'd shorted pay before. Checked your books since. Clean. People CAN change. Statistically rare. Noted."

---

### 3.4 Hedge Witch — "Old Nettle"
*Voice: cackling, cryptic, secretly kind. Speaks to plants mid-sentence.*

**INTERVIEW**
- Approach: "Ohh, this one runs a tavern AND a guild? Greedy. — Hush, basil, I'm talking."
- Her questions: "What do you grow here? And 'profits' is a cheeky answer, not a wrong one." / "Fresh reagents or dried? Lie and the basil will know."
- Honesty check: "That gold trim by the door — real, or gilded?"
  - [P] Truth ("Gilded.") → "HA! Good. Real gold by the door means fake everything else." `{told_truth}`
  - [P] "Real!" (if gilded) → "Mmm. The basil doubts you." SUSPICIOUS. `{lied_interview}`
- Quirk hint: "I sleep poorly where nothing grows."
- Sign: "Fine, fine. I'll want a windowsill. A SUNNY one. The ferns are non-negotiable."

**SIGNED**
- "Your cellar has excellent mold. That's a compliment. From me it's a compliment."
- "Drink this. — Because you look tired and it's Tuesday. Don't interrogate kindness."

**TRUSTED**
- "The Rogue thinks I don't see her on the roof. The ROOF GARDEN sees her, dear. We compare notes."
- "Brewed something for the Barbarian's nerves. It's chamomile. Don't tell him. He thinks it's a potion. It IS, emotionally."

**DEVOTED**
- "I've cursed three landlords in my life. You I water the plants for. Career growth, this is."
- "When the garden blooms in spring, that's not the season, poppet. That's the house being happy. Houses do that. Ask them."

**QUIRK LINES (garden/nature decor)**
- Garden built: "NOW we're a proper establishment. The ferns approve. The ferns are very judgmental. This is huge."

**RAVEN — character moments**
- "Old Nettle found herbs on-site. She can brew mid-quest — party heals — but it delays them past nightfall. Things happen past nightfall."
  - [P] Brew → heal party, +time, small night-risk
  - [P] Press on → normal

**QUEST RETURNS**
- Triumph: "Went beautifully. Also I brought back cuttings. ILLEGAL cuttings? The forest didn't SAY no."
- Success: "Fine, fine, all fine. The moss out there, though. Exquisite. I took some. I took a lot."
- Setback: "Someone touched the mushrooms I said not to touch. I'll let you guess. Rhymes with 'Sbarbarian.'"
- Disaster: "Bad ground out there. Old and angry. We'll not go back without wards. Real ones. Mine."

**TIER-UPS**
- → Witch: "'Witch,' official and everything. Forty years, and all it took was surviving them."
- → Archdruid: "Archdruid Nettle. The ferns are BESIDE themselves. Someone fetch the ferns a chair."

---

## 4. RARE HEROES

### 4.1 Disgraced Noble — "Lady Elissa Vane"
*Voice: precise, formal, carrying a wound she never names directly.*

**INTERVIEW** *(3 questions; one reads your record)*
- Approach: "I'll not waste your evening. You know my name, or you'll learn it from someone crueler. Ask what you wish."
- Q1: "Does this guild keep its word when keeping it costs something?"
- Q2 (record check): "Your ledger shows a poach attempt this season." *(only fires if true)* "Explain it to me as you'd explain it to the hero you took."
  - [P] Own it plainly → "At least you don't dress it as virtue. But I cannot sign under that shadow. Perhaps when it's older." *(returns to queue after her quirk window)*
  - [P] Excuse it → "Mm. My father excused things beautifully too." *(leaves, longer cooldown)*
- Q3: "Why me? Speak plainly — my rank, my arm, or my story?"
  - [P] Any honest answer → accepted. Flattery → "The last hall that flattered me is the reason I'm in taverns." SUSPICIOUS.
- Sign: "Then witness it: I serve this hall. Fully. There are no half-measures left in me."

**SIGNED**
- "The training yard is adequate. I've drilled in worse. I was *raised* in better. Neither matters now."
- "You needn't tiptoe about my house's fall. Silence is heavier than questions."

**TRUSTED**
- "My father taught me that honor is a currency. He then debased it. I'm restoring the exchange rate personally."
- "The Minstrel asked to write my ballad. I said only if it's accurate. He said accuracy costs extra. I respect him enormously."

**DEVOTED**
- "When my house fell, I made a list of everything I'd lost. Rank. Lands. Name. I've stopped keeping the list. This hall is why."
- "You never once asked what I did. You watched what I do. That is the entire difference between this place and everywhere."

**QUIRK LINES (won't join post-poach guilds)**
- (as prospect, guild poached recently): "I saw the notice board. Not yet. Perhaps not ever. Prove me wrong slowly."

**RAVEN — character moments**
- "Lady Vane recognizes the smuggler lord — an old family 'friend.' She can leverage the history (fast, personal cost) or handle it as a stranger would (clean, slower)."
  - [P] Use the history → quest shortens, her loyalty dips one tick, later fireside scene unlocks `{vane_past}`
  - [P] As a stranger → normal, small loyalty tick ("Thank you for not spending me.")

**QUEST RETURNS**
- Triumph: "Done, and done properly. The distinction matters more to me than the outcome."
- Success: "Completed to the letter of the contract. And its spirit. I audit both."
- Setback: "We fell short. The fault has an owner and I am she. Corrections tomorrow at dawn."
- Disaster: "I have written the client a full account, unvarnished. Honor survives failure. It does not survive the covering of it."

**POACH DEFENSE**
- "You offer me a *better* hall? I had the best hall in the realm once. I've since learned what halls are for. Leave."

**TIER-UPS**
- → Knight-Errant: "Errant. Wandering. Yes — but wandering *from* somewhere now, not merely away."
- → Redeemed Countess: {vane_past: "You know what I spent to get here."} "The title returns. It sits differently — earned things weigh more, and carry easier. Our guild's name rises with it. THAT is the part I wanted."

---

### 4.2 Treasure-Mad Dwarf — "Brokka Goldeneye"
*Voice: booming, gleeful, does arithmetic out loud, zero shame.*

**INTERVIEW**
- Approach: "SHINY door handles! Gilded, but shiny! You pass the first test, which was door handles!"
- Q1: "Cut of the loot — number, now, no adjectives."
- Q2: "What's the BIGGEST thing this guild ever hauled home? Round up, I'll allow it."
- Q3 (honesty check): "That chandelier — what'd it cost? I'll know if you pad it. I appraise ceilings RECREATIONALLY."
  - [P] Truth → "CORRECT to within four percent! Oh, I like you. You count things." `{told_truth}`
  - [P] Pad it → "HA! Padded by a third! Sloppy. We'll work on you." SUSPICIOUS (amused version).
- Sign: "DONE! Witnessed by this coin, which is now mine, as a signing fee. Custom of my people. The custom is I like coins."

**SIGNED**
- "Your vault's a shoebox with delusions. I've drawn plans. The plans have plans."
- "Counting the till isn't a CHORE, it's a HOBBY, and I'm ELITE at it."

**TRUSTED**
- "Put the good plunder where FOLK CAN SEE IT. Hidden treasure is just anxious rocks."
- "The Knight appraises food, I appraise everything else. Between us this tavern's fully audited and DELICIOUS."

**DEVOTED**
- "I've held crowns, love. Actual crowns. And I'm telling you — a full hall with your name over the door out-shines the lot."
- "My clan measures wealth in what you'd never sell. By that count — and ONLY that count — I'm richest here. Don't quote me. It's off-ledger."

**QUIRK LINES (loyalty tied to displayed gold)**
- Gold decor placed: "NOW THAT'S A WALL. That's a wall that KNOWS ITS WORTH."
- Bare walls, 3+ sessions: "The walls are NAKED, boss. I avert my eyes out of respect."

**RAVEN — character moments**
- "Brokka's found a sealed vault off the main haul. Not in the contract. Her assessment: 'finders keepers is BASICALLY law.'"
  - [P] Crack it → bonus loot chance, honesty ding, Vane disapproves if signed
  - [P] Report it to client → reputation up, Brokka grumbles ("Honor doesn't SPEND, but FINE.")

**QUEST RETURNS**
- Triumph: "HAUL! H-A-U-L! Someone get the good scales, the DAY scales, the CELEBRATION scales!"
- Success: "Standard yield. 'Standard.' The saddest word in commerce."
- Setback: "We dropped a crate in the river. I know its exact worth. I will recite it. QUARTERLY. In mourning."
- Disaster: "...Left the whole haul behind to carry Grunwald out. Correct trade. Don't ask me to say it twice, it physically hurt."

**POACH DEFENSE**
- "Double the gold? Show me the VAULT, not the promise. ...Thought so. All pitch, no purse. NEXT."

**TIER-UPS**
- → Delver: "Deeper digs, richer seams! The maths of it! THE MATHS!"
- → Kingsminer: "Kingsminer Brokka. Every party I bless comes home HEAVIER. It's not magic, it's ATTITUDE. Fine, it's slightly magic."

---

### 4.3 Masked Duelist — "The Gray Feather"
*Voice: courteous, spare, speaks in fencing terms. A mystery that never overplays itself.*

**INTERVIEW**
- Approach: "I won't give a name. I'll give my terms, my blade, and my word. Historically the name was the least reliable of the four."
- Q1: "What quality of steel do you provide? A duelist is half equipment. The better half stays private."
- Q2: "When your heroes are challenged — poached, you call it — who stands with them?"
- Q3 (honesty check): "Do you want the mask off? Answer honestly. Most owners lie here, curiously."
  - [P] "Yes, honestly, I'm curious." → "Honest AND curious. The mask stays — but I'll remember you asked without pretending otherwise." `{told_truth}`
  - [P] "Doesn't matter to me." (a polite lie) → "Everyone says that. Everyone stares at breakfast." SUSPICIOUS (mild).
- Sign: "Then en garde, employer. Terms accepted."

**SIGNED**
- "Your training yard: acceptable footwork surface. Sand. Sand forgives. Cobblestone teaches."
- "I've noted three habits of yours. Duelists notice. It's not personal until it is."

**TRUSTED**
- "The Mercenary asked what I'm hiding. I said 'my face.' He said 'fair.' I enjoy this guild's efficiency."
- "When a rival tempts one of ours, send me. Defense is my discipline — offense merely pays for the lessons."

**DEVOTED (max loyalty → the reveal scene)**
- *(scripted scene, once)*: "You've never pried. Six seasons, and not once. So —" *(removes mask — cosmetic moment, unique per-player color roll)* "— the face is ordinary. The trust wasn't. It never is."
- After reveal: "Strange, breakfast without the mask. The Barbarian dropped his ENTIRE bowl. Worth it."

**RAVEN — character moments**
- "The Gray Feather has been challenged to single combat by the bandit champion — winner takes the pass, no bloodshed for the rest."
  - [P] Accept the duel → all-or-nothing band swing on Feather's skill
  - [P] Decline → party fights conventionally ("Noted. Sometimes the wise parry is refusal.")

**QUEST RETURNS**
- Triumph: "Three exchanges. It ended in the third. They'll retell it as ten. Let them."
- Success: "Resolved. My tally: touched once. The lesson is already scheduled."
- Setback: "I was beaten to the line. It happens. It happening TWICE does not."
- Disaster: "The mask took a cut tonight. Closer than I say aloud. The repair is... symbolic. Give me the evening."

**POACH DEFENSE (their specialty — defends OTHERS)**
- Defending a guildmate: "You pitch well. I riposte better. This conversation is concluded."
- Own defense: "Recruit a duelist by ambush? You've already lost the bout and don't know it. Feather's mercy: walk away."

**TIER-UPS**
- → First Blade: "First Blade of the hall. It means, when trouble calls on any of ours — I answer first. That has always been the point of the sword."

---

### 4.4 Storm Mage — "Iriseth"
*Voice: still, exact, faintly crackling. Chaos-averse to her core.*

**INTERVIEW**
- Approach: "Your hearth is steady and your roof doesn't leak. You'd be surprised how few interviews survive my first minute."
- Q1: "Show me the gear you'd issue me. Not describe. Show." *(gear stat checked live)*
- Q2: "Has anyone in this hall ever lied to you and remained?" 
- Q3 (honesty check): "Is this a calm house? Think before answering. I will be living in your answer."
  - [P] Truth (open board on: "It gets loud. We take risks.") → "Then I decline — today. Turn the chaos off and ask again. I appreciate that you didn't hide it." *(quirk taught honestly)*
  - [P] Lie (board on, claim calm) → signs → discovers board → severe loyalty penalty + line: "You built a storm and called it weather. I *am* the storm, keeper. I know the difference." `{lied_interview}`
- Sign: "Acceptable. I'll take the quiet room. There is a quiet room? ...There will be a quiet room."

**SIGNED**
- "Your chimney draws well. Small praise. I mete praise exactly."
- "Do not seat the Minstrel near my study hours. This is a safety notice."

**TRUSTED**
- "Storms are not chaos, keeper. They are order at a scale that frightens people. I relate to them professionally."
- "The Witch leaves chamomile at my door. We have never discussed it. We never will. It is a perfect arrangement."

**DEVOTED**
- "I have taken lightning into my hands and held it. The harder trick was letting a place hold me. You may note the tense."
- "When the Peaks rage and the others look up in fear — I look up and see the way home lit for me. Your doing, that reading of it."

**QUIRK LINES (open board = loyalty drain)**
- Board switched on: "The listing is public tonight? Then I'll be in my room, warding it, and revising my opinions."
- Board off after on: "Quiet again. Good. I've un-revised. Most of them."

**RAVEN — character moments**
- "Iriseth reads a natural storm ahead. She can spend herself to steer it — party sails through, she returns exhausted — or the party shelters and loses a day."
  - [P] Steer it → fast, she needs rest after (unavailable next quest)
  - [P] Shelter → +time, no cost

**QUEST RETURNS**
- Triumph: "The sky cooperated. It rarely does. Even the weather knows a good crew."
- Success: "Complete. Precisely as forecast. I do enjoy a forecast honored."
- Setback: "Variables exceeded the model. Mine, not the plan's. I've adjusted the model. I always adjust the model."
- Disaster: "There are storms I cannot steer. Today had one. Give the others tomorrow off — sky's orders, and mine."

**POACH DEFENSE**
- "Your master's hall is louder, larger, and listed on every board in the province. You've described my nightmare as a prize. Go."

**TIER-UPS**
- → Stormcaller: "Stormcaller. The clouds and I are on speaking terms now. First-name terms come at the next rank."
- → Tempest Archmage: "The high peaks open to us. Few halls are granted that weather. Fewer earn it. Pack for altitude, keeper."

---

## 5. LEGENDARY HEROES

### 5.1 The Retired Hero — "Aldric Once-Dragonsbane"
*Voice: quiet gravity. Speaks little, means everything. Multi-scene courtship: three visits before he'll sit.*

**VISIT 1 (record gate: never-failed-contract only)**
- Enters, orders one ale, watches. On approach: "I'm not here to sign anything. I'm here because your record says something rare, and I wanted to see if the room matched the ledger. It might. Good stew." *(leaves)*

**VISIT 2 (several sessions later)**
- "Your farmhand — Bram? He held the door for three strangers and checked the fire twice. You didn't train that. You attracted it. That's harder." *(asks ONE question)* "Why do you keep the guild's word when breaking it would pay?"
  - [P] Any answer given honestly (no 'right' answer exists) → he nods. *(leaves)*
  - [P] A polished, flattering answer → "Hm. Rehearsed. I'll come back when it isn't." *(delays visit 3)*

**VISIT 3 (the interview proper)**
- "Third visit. You never once pushed. That was the last test — patience is honor's quietest form. Ask me your questions; I'll allow all three, and I'll answer them true, which is more than most legends manage."
- His terms: no gold, no gear. "Keep the record clean. That's my whole contract. Break it and I won't storm out — I'll simply be gone, and the room will feel it."
- Sign: "Then I'll take the chair by the fire. The one nobody sits in. Rooms save those chairs. They know."

**SIGNED / TRUSTED / DEVOTED** *(his registers move faster — his aura is the point)*
- SIGNED: "Don't introduce me by the old name. 'Aldric who helps with the heavy jobs' will do."
- TRUSTED: "The young ones fight better when I'm in the yard. I don't teach anything. I just stand there. Take the lesson, keeper: mostly, standing there is the job."
- DEVOTED: "I retired because every hall wanted the Dragonsbane. This one only ever asked for Aldric. So the Dragonsbane came back on his own. Funny how that works."

**RAVEN — character moments**
- "Aldric recognizes the beast from the old days. He can end it alone — certain, but the young ones learn nothing — or direct them while he holds back."
  - [P] Alone → guaranteed Success (never Triumph — "quick isn't the same as good")
  - [P] Direct them → normal odds, all party members gain bonus XP `{aldric_lesson}`

**QUEST RETURNS**
- Triumph (party earned it): "Wasn't me. That's the best report I've filed in twenty years."
- Disaster: "We were beaten. Everyone's alive, which means we were beaten *well*. That's a skill too. Rest them."

**POACH DEFENSE**
- "Son, I've refused kings. And I was RUDER then."

**TIER-UPS**
- → Returned: "Word's out that I'm working again. Let them talk. The fire's warm and the record's clean."
- → Legend Reborn: {aldric_lesson: "The ones I taught are teaching now. THAT's the legend part. The dragon was just Tuesday."}

---

### 5.2 Dragon-Blooded Orphan — "Ember"
*Voice: young, hungry to matter, grows across five stages from uncertain to steady. The long-arc heart of the game.*

**INTERVIEW**
- Approach: "I know I don't look like much. Everyone starts the interview that way, so I thought I'd save you the — the face you were about to make. That one. Yes."
- Q (only one, and it's earnest): "If I'm bad at this at first — and I will be — do people here get to *become*, or just to *be*?"
  - [P] Truth in either direction works; a promise you can't check works too — Ember believes you. Betraying it later is the mechanic. `{ember_promise}`
- Sign: "Okay. Okay! You won't — I mean. You might regret it for a while. But not at the END. I'm good at ends."

**STAGE VOICES (register per upgrade stage, not just loyalty)**
- Stage 1: "I fed the chickens and only set fire to zero of them! Writing it on the board. Achievements board. We should have one."
- Stage 2: "Bram's teaching me shield grip. Korr watched for a WHOLE minute and didn't leave. That's a Korr standing ovation."
- Stage 3: "Something's changing. My hands are warm all the time now. The Witch says drink the tea and stop asking. So: tea."
- Stage 4: "I steered the fire today. It listened. It's been mine all along, hasn't it — it was just waiting for me to stop flinching."
- Stage 5 (Dragonheir): "You signed a kid who could barely carry firewood. I remember the exact face you didn't make. That's why this — all of this — is yours to count on. Always."

**QUIRK (unpoachable at max loyalty)**
- Poach attempt post-max: "You're offering me a future? I'm STANDING in mine. It has a fireplace and everybody knows my name. Bye!"

**RAVEN — character moments**
- (stage 3+) "Ember's power flared mid-quest. She can lean in — wild, strong — or hold it back like she's practiced."
  - [P] Lean in → high variance, +arc progress
  - [P] Hold → steady, small loyalty tick ("You told me control counts double. I heard you.")

**MEMORY HOOKS**
- {ember_promise} at stage 5: quotes YOUR interview answer back, verbatim. *(store the actual choice text — the game's single best-remembered line.)*

---

### 5.3 The Rival Poacher — "Sable"
*Voice: professional charm with the mask slipping over time. Appears only after 3+ defended poaches.*

**FIRST APPEARANCES (pre-recruitment, scripted beats)**
- Background, Gildport quests: a figure in gray noting your heroes' names in a ledger.
- The attempt (Act IV, ~h24): targets your highest-loyalty hero. Duel opener: "Nothing personal. I'm the best at this, and your people are the best worth taking. Consider it a compliment with teeth."
- On losing the duel: "...Huh. They didn't even *hesitate*. I've turned heroes who cried at their own signing. What are you *feeding* them?" *(exits — flag `{sable_beaten}`)*

**INTERVIEW (appears in queue post-{sable_beaten})**
- Approach: "Before you throw me out: I'm off the clock. I came to ask a professional question. Why don't yours *leave*? I've studied your gold. It's fine. Fine doesn't hold people. Something else is holding them and I want to know what, because I can't SELL against it."
- Honesty check: "Would you ever use me the way my old master did — point me at halls and say fetch?"
  - [P] Truth ("I've poached before / I might.") → "Honest. Good. Then here's MY term: I defend. I never fetch. My tokens, retired." `{told_truth}`
  - [P] "Never." (if your record shows poaches) → "Your ledger disagrees. Try again — I'll allow it once. Occupational courtesy." 
- Sign: "Then hire the wolf to watch the door. It's a very old arrangement. It works because the wolf finally *wants* the house to stand."

**SIGNED → DEVOTED (compressed — she's a late-game signing)**
- SIGNED: "I've audited your defenses. Wrote a report. Burn it after reading — I'm serious, I know six people who'd pay for page two."
- TRUSTED: "Your Duelist and I disagree on method and agree on everything else. We've scheduled a rivalry. Tuesdays."
- DEVOTED: "I spent ten years learning why people leave. Turns out I was collecting reasons to stay. Filed under: irony, career-ending."

**POACH DEFENSE (as Head of Security)**
- "Oh, I *wrote* that pitch. Third clause hides the pay cut, the 'family' line lands at the door — I trained your recruiter, sweetheart. Class dismissed."

**TIER-UPS**
- → Guildbreaker: "The old title, worn honest-side out. I break guilds, keeper. Now it's the ones that come for ours."
- → Head of Security: "Official, then. The wolf has a KEY. Historic. Someone should paint it."

---

## 6. PATRON AMBIENT CHATTER (by Act)

*Shared pool, 8–12 lines active per act. Patrons are unnamed; lines rotate. These are the reputation system made audible.*

**Act I — Unknown**
- "Never heard of this place. The stew's the audition, then."
- "Is the fire always this smoky, or is that ambiance?"
- "Someone said this used to be old [Uncle]'s hall. Shame what happened. Or — nobody actually knows what happened."
- "One hero on the books? Bold to call it a 'guild,' but I admire arithmetic optimism."

**Act II — Local → Respected**
- "The valley's talking about the crew that cleared the crypt road."
- "That's the healer who wouldn't take the Baron's bribe. In THIS tavern. Sitting RIGHT there."
- "My cousin's caravan got through Thornwood untouched. First time in years. Guess whose work."
- "Heard the big fellow screamed the whole job and finished it anyway. That's a new kind of brave and I'm for it."

**Act III — Respected (rival gossip goes dynamic)**
- "[RivalGuildName] tried to poach from here last week. Went home embarrassed, I heard." *(pull from real defense events)*
- "Two guilds bidding on the same rogue. It's like a royal wedding but with more lockpicks."
- "Gildport merchants only post here now. Says something."
- "I don't gamble, but if I did, my coin's on this hall's board over the [RivalGuildName] board."

**Act IV — Renowned**
- "They say the Storm Mage signs for no one. Yet here she is. Nursing a tea. Like a PERSON."
- "Is it true about the masked one? Don't point. DON'T point."
- "A deadly contract went up last week and three of theirs volunteered. Volunteered!"
- "My daughter wants to be 'a tavern hero' now. Not a knight. A tavern hero. This place broke the job market."

**Act V — Legendary**
- "I traveled two weeks to drink here. Two weeks! The ale's fine. That's not the point and you know it."
- "That's HIM. By the fire. The chair nobody sits in. He SITS in it."
- "They say the guildmaster of [CondescendingGuildmaster]'s hall asked for a table last week. ASKED."
- "Tell your grandkids you drank here before the songs. That's the whole reason I'm here, honestly."

---

## 7. SHARED RAVEN POOLS (risk forks & twist reveals)

*Character-agnostic; the party's composition fills the flavor slot.*

**Risk forks**
- "The tunnel splits. Left: mapped and modest. Right: unmapped, and the draft smells like gold. [Party leader] awaits your word."
- "The escort's ahead of schedule. Push through the night to Triumph pace, or camp safe and hold Success?"
- "The beast's lair is right there — but so is its bigger sibling's. Take the contract's target only, or both bounties?"

**Twist reveals**
- "The ransom note is a lie — the 'captive' is in on it. Spring the trap on THEM, or walk away with the fee and the secret?"
- "The relic is cursed. [Cleric if present: 'Maren can carry it safe.' / else: 'No one can carry it safe.'] Deliver anyway, or renegotiate?"
- "The client's 'stolen' cargo has the client's OWN smuggling mark. Finish quietly, or ask pointed questions at pointed-sword distance?"

**Neutral auto-resolutions (raven expired)**
- "No word came, so [leader] chose the cautious road. The party continues."
- "The moment passed. [Leader] shrugged and kept to the plan."

---

## 8. TAVERN FLOOR — STAFF & FLOOR-TASK BARKS

**Serving (player-performed)**
- Patron: "Stew, and don't be shy with the bread."
- Patron: "Whatever the big nervous fellow's having. He seems trustworthy about food."
- On fast service: "Quick hands! You run the guild AND the floor? Marry my daughter. Joke. Half a joke."

**Brawl events**
- Warning: "Oi — table four's arguing about whose guild is better. Yours or yours. Both are yours. They're too drunk to know."
- Resolved by player: "Broken up with WORDS? In THIS economy?"
- Missed (decor damage): "The chair lost. The chair always loses."

**Eavesdrop drops (hint templates)**
- Quirk clue: "…the dwarf lass? Saw her count the candlesticks. TWICE. Lovingly."
- Quest hint: "…crypt road's quiet but the miller swears the well whispers. Wells don't whisper. Usually."
- Rival intel: "…[RivalGuild]'s down two heroes this month. Bad contracts. Word travels."

**HIRED STAFF (automation characters)**
- Barmaid "Odile" (auto-serve), hire line: "I've run floors bigger than this and ruder than you'd believe. Point me at the taps and stay out of my lane, love."
  - Ambient: "Table six is handled. Table six is ALWAYS handled."
- Bouncer "Tobbin" (auto-brawls), hire line: "I don't hit folk. I *loom*. Ninety percent of this job is credible looming."
  - Ambient: "Quiet night. My favorite kind. All my nights are my favorite kind, eventually."
- Gossipy Regular "Fenna" (auto-eavesdrop, 1 clue/session), hire line: "Buy my ale and I'll tell you what this room says when you're in the cellar. It says a LOT."
  - Ambient: "Not gossip. INTELLIGENCE. Gossip is when it's about ME."

---

## 9. STORY NPCs

**The Uncle's Letter (hour one, read aloud)**
- "If you're reading this, the hall is yours, and I'm somewhere the ravens don't fly. Three things. One: the fire never goes fully out — there's a trick to the banking, ask nobody, figure it out, it's good for you. Two: heroes don't follow gold, whatever they say at the bar. They follow how you treat the ones who cost you nothing. Three: when a man from the old rival hall comes asking — and he will — count the spoons after. The rest, you'll write yourself. It's a good hall. It was never about the ale. — Your uncle."

**Condescending Guildmaster — "Master Hollis" (recurring foil)**
- Act I visit: "So YOU'RE the inheritance. Charming little... venture. I give it a season. I'm rarely wrong — ask anyone I allow to speak."
- Act II return: "Still open. Huh. The crypt road job — that was yours? ...Adequate work. For the building it came from."
- Act IV encounter: "People keep saying your hall's name in MY hall. Make them stop. — That was a compliment. It exits me poorly."
- Act V (asks for a table): "I'd like... a table. Yes, tonight. No — no, there's no punchline, just the table. ...The stew, they say, is honest. I could stand some honest."

**Antagonist Rival Guild — "The Gilded Chain" (Acts IV–V)**
- Herald's challenge: "The Gilded Chain contracts what it cannot poach and buries what it cannot contract. Your hall has refused twice. There is no third refusal — there is only the season in which you learn what the Chain does instead."
- Finale beat (their master, beaten): "You out-bid nothing. You out-paid no one. What WAS it? ...No. Don't answer. That's the one purchase I never learned to make, and I'll not start by begging it."

---

## 10. SYSTEM BARKS (screens & ceremonies)

**Welcome-back screen**
- "The fire held. The till filled. And two travelers are asking after the owner…"
- (big haul) "Word of your hall traveled while you slept. So did the coin."

**Tier-up ceremony (shared frame, hero line slots in)**
- Herald patron: "Raise your cups! The hall marks one of its own —" *(hero's tier-up line plays)* "— and the round is on the house!" 

**Reputation tier-up**
- → Respected: "The valley knows the hall's name now. Ledgers open easier. So do doors."
- → Legendary: "There are halls, and there are the halls the songs mean. Yours is the second kind now. Hang the crown sign."

**Poach — defense victory (system frame)**
- "[Hero] stays. The stranger leaves lighter — one token poorer, one lesson richer. Compensation credited."

**Deadly Contract acceptance (heavy flavor gate)**
- "The notary requires a signature in red ink. Read twice: those who take this road are paid like legends BECAUSE some do not walk back. Sign, or leave the quill."

---

## 11. WRITING & EXPANSION NOTES

- Every hero needs their register pools topped to 8–12 lines each before ship; this document seeds 3–5 per register — the voices are established, extend in-voice.
- Memory-hook flags used here: {told_truth}, {lied_interview}, {first_setback}, {cave_moment}, {vane_past}, {aldric_lesson}, {ember_promise}, {sable_beaten}. Store per-hero; one callback line each is enough.
- The AI dialogue layer (Roblox Text Generation API), when added, should be prompted WITH each hero's voice notes (the italic line under each name) and FORBIDDEN from: revealing quirks/stats outright, contradicting register tone, or resolving mechanics. Scripted lines above always take priority when their trigger fires.
- Localization note: puns (Brokka's "H-A-U-L", Fenna's gossip line) need per-language rewrites, not translations — flag them.

*End of script document.*
