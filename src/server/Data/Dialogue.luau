--!nonstrict
-- Dialogue.luau — all scripted lines, keyed (master script doc → data).
-- Pure data: interviews, loyalty registers, quirk lines, character ravens,
-- quest returns, tier-ups, memory hooks, patron chatter, floor barks, story NPCs.
-- Register pools are seeded 3–5 lines each; top up to 8–12 in-voice before ship.

local Dialogue = {}

-- ============================================================
-- Interview framework (script doc §1)
-- Each interview: ordered NODES. A node = prompt + options.
-- Option fields: text · reply · flag ("told_truth"|"lied_interview") · refuse (hero walks)
-- After nodes, the player may ASK up to 2 questions, then Sign / Negotiate / Wait.
-- ============================================================

Dialogue.GenericInterview = {
	approach = "You the one who runs this place?",
	truthReply = "Huh. Most owners dress it up. I'll remember you didn't.",
	sign = "Then we have terms. Where do I put my boots?",
	walkAway = "Maybe another season. Keep the fire lit.",
}

Dialogue.Heroes = {
	farmhand = {
		voice = "Plain, earnest, understatement. Never uses two words where one does.",
		interview = {
			approach = "Heard there's coin here for a man with a strong back. That true, or just talk?",
			nodes = {
				{
					id = "pay",
					prompt = "Pay's steady?",
					options = {
						{ text = "Steady as I can make it.", reply = "Good enough." },
						{ text = "Best pay in the valley!", reply = "...If you say so.", flag = "lied_interview" },
					},
				},
				{
					id = "honesty",
					prompt = "Place looks... lived-in. Business good?",
					options = {
						{ text = "It's a mess, honestly.", reply = "Mess I can fix. Lies I can't.", flag = "told_truth" },
						{ text = "Booming.", reply = "...Right.", flag = "lied_interview" },
					},
				},
			},
			ask = {
				want = "Steady coin. Warm meals wouldn't hurt.",
				worked = "Da's farm, then whoever paid. Fields teach you to finish what you start.",
				know = "I work better on a full stomach. Just saying.",
			},
			sign = "Alright, boss. Point me at something.",
			walkAway = "I'll think on it. The stew smells fair, so I might be back.",
		},
		registers = {
			signed = {
				"Job's a job.",
				"You feed your people here, or is that extra?",
				"Wolves again? Fine. Wolves it is.",
			},
			trusted = {
				"My da worked a field thirty years for less thanks than you give in a week.",
				"Stew's good tonight. Don't tell the cook I said.",
			},
			devoted = {
				"This is the first place felt like mine since the farm.",
				"The new ones ask me what you're like. I tell 'em: fair. That's the whole review.",
			},
			trusted_told_truth = "You know what I liked? First day, you said the place was a mess. It was. You didn't pretend.",
			devoted_lied = "You stretched the truth when I signed. I knew. Signed anyway. Don't do it again, yeah?",
		},
		quirkLines = {
			fired = "Now THAT'S a proper bowl. Alright. ALRIGHT. Let's work.",
			starved = "Kitchen cold again? A man notices.",
		},
		raven = {
			trigger = "low_confidence",
			text = "Bram's asking if you're sure about this one, boss. He'll go if you say go.",
			options = {
				{ text = "Go.", effect = "widen" },
				{ text = "Pull back.", effect = "safe", loyaltyTick = true, reply = "You called us home. Noted." },
			},
		},
		returns = {
			Triumph = "Went well. Don't ask me to say more than that.",
			Success = "Done. What's next?",
			Setback = "Worth it, boss.",
			Disaster = "...Give me a day. Maybe two. Then we talk about what went wrong.",
		},
		tierUps = {
			"A real sword. Da would've laughed. Then he'd have cried a bit. Same as me, don't look.",
			"Me. Teaching. If you'd told the wolves-job me...",
		},
		memoryHooks = {
			first_setback = "Started with wolves in Thornwood. Look at us now.",
			survived_disaster = "I still dream about that job sometimes. We don't send greens on those. Promise me.",
		},
	},

	minstrel = {
		voice = "Theatrical, self-deprecating, allergic to silence.",
		interview = {
			approach = "Ah! An audience of one! My favorite size — statistically my only size.",
			nodes = {
				{
					id = "laugh",
					prompt = "Be honest — do people *laugh* here, or merely drink until they think they do?",
					options = {
						{ text = "Mostly the second one, so far.", reply = "Honesty! The rarest heckle. I'm in the right room." },
						{ text = "They roar nightly.", reply = "Marvelous. I shall audit that claim from the stage.", flag = "lied_interview" },
					},
				},
				{
					id = "honesty",
					prompt = "Will I be paid in coin, or in 'exposure'? I've been paid in exposure. I nearly died of it. Twice.",
					options = {
						{
							text = "Coin's thin right now.",
							reply = "Thin coin, honestly offered, is a ballad. Fat coin, falsely promised, is a dirge. I accept.",
							flag = "told_truth",
						},
						{
							text = "You'll be rich.",
							reply = "Marvelous! I shall hold you to that in the most public and musical way possible.",
							flag = "lied_interview",
						},
					},
				},
			},
			ask = {
				want = "An audience that stays. And honesty — liars always want a different song than the true one.",
				worked = "Every taproom from here to Gildport. Thrown out of the good kind of loud AND the bad kind.",
				know = "A minstrel without a stage is just a man complaining in rhythm.",
			},
			sign = "Then strike up the — well. Me. Strike up me.",
			walkAway = "I shall tour the competing establishments. Briefly. Devastatingly.",
		},
		registers = {
			signed = {
				"No stage yet, I see. I shall sing to the soup. The soup, at least, listens.",
				"Request line is open. Refusals also open.",
			},
			trusted = {
				"I wrote a verse about you. It's mostly flattering. The rhyme scheme forced one insult.",
				"You know why I sing for honest folk? Liars always want a different song than the one that's true.",
			},
			devoted = {
				"Every tavern has a sound. Yours is the good kind of loud. I'd know — I've been thrown out of the other kind.",
				"When I go — years from now, dramatically, mid-song — put the lute over the fire. It'll want to stay.",
			},
			devoted_told_truth = "My best song is still the one about the owner who said 'coin's thin' with a straight face. Honesty in E minor. Beautiful.",
		},
		quirkLines = {
			fired = "A STAGE. A real — everyone SHUT UP, I mean, gather round!",
			starved = "I performed in the corner today. The corner. My mother was right about everything.",
		},
		raven = {
			trigger = "negotiate",
			text = "Perrin says the guards look bored. Permission to 'deploy the funny song'? Consequences unknowable.",
			options = {
				{ text = "Deploy the song.", effect = "widen" },
				{ text = "Deny.", effect = "safe", reply = "A tragedy. It was VERY funny." },
			},
		},
		returns = {
			Triumph = "They wept! With joy! Mostly joy! Definitely more than half joy!",
			Success = "A competent performance. Ugh. 'Competent.' Don't put that on my poster.",
			Setback = "The crowd turned. Crowds do that. Like weather, or geese.",
			Disaster = "...I don't want to sing about this one. That's how you'll know it was bad.",
		},
		tierUps = {
			"'Bard' — official! Legally I may now be insufferable in THREE more counties.",
			"They say a Songweaver's songs bring coin through the door. Watch the till, boss. Watch it dance.",
		},
	},

	rogue = {
		voice = "Clipped, wary, exits conversations early. Trusts actions only.",
		interview = {
			approach = "Saw your board. Saw your locks. The locks are bad. Talk fast.",
			nodes = {
				{
					id = "books",
					prompt = "Who else knows I'm here? You keep books on your people?",
					options = {
						{ text = "Just me. Ledger stays locked.", reply = "The ledger lock is also bad. I'll fix it." },
						{ text = "Everyone will know your name soon!", reply = "Wrong answer. Badly wrong. Lucky for you I'm still sitting.", flag = "lied_interview" },
					},
				},
				{
					id = "honesty",
					prompt = "This guild clean? And think before you answer, because 'yes' is the wrong answer. Nobody's clean.",
					options = {
						{ text = "We've cut corners.", reply = "Good. Clean guilds lie the biggest.", flag = "told_truth" },
						{ text = "Spotless.", reply = "Sure it is.", flag = "lied_interview" },
					},
				},
			},
			ask = {
				want = "Coin. Good gear. Nobody asking questions. You're using up your questions.",
				worked = "Crews. Plural. I walked out on all of them. They earned it.",
				know = "Crowds are how you get remembered. I don't do remembered.",
			},
			sign = "Fine. I'm not shaking hands. It's nothing personal. It's fully personal.",
			walkAway = "Too many faces in here tonight. I'll find you when it's quieter.",
		},
		registers = {
			signed = {
				"Don't put my name on the board. Initials. One initial.",
				"Your back door sticks. Fixed it. You're welcome. Don't ask why I checked.",
			},
			trusted = {
				"Fixed your locks. All of them. Slept better after. That's — whatever. Forget it.",
				"You want to know about rival taverns, ask. Knowing things is the one thing I'm generous with.",
			},
			devoted = {
				"I've walked out on every crew I ever ran with. You'll notice I'm still here. Notice quietly.",
				"If anyone asks, I don't like this place. If anyone touches this place, they'll learn different.",
			},
			trusted_told_truth = "You said 'we've cut corners' the day we met. Most honest thing an owner ever told me. Still true?",
		},
		quirkLines = {
			prospect_blocked = "Too many faces in here tonight. I'll find you when it's quieter.",
			fired = "Busy night. I'll be on the roof. Yes, we have a roof. No, I'm not telling you how I get up there.",
		},
		raven = {
			trigger = "retrieve",
			text = "Vex found a side door into the vault. Off the plan. Her words: 'trust me or don't.'",
			options = {
				{ text = "Trust her.", effect = "widen" },
				{ text = "Stick to plan.", effect = "safe", reply = "Your call. The boring call, but yours." },
			},
		},
		returns = {
			Triumph = "In. Out. Nobody saw. That's a good day.",
			Success = "Done. One of them saw my face. Handled it. Don't ask.",
			Setback = "It went loud. I hate loud.",
			Disaster = "Someone talked. Wasn't me. I'll find who.",
		},
		tierUps = {
			"Promotion, huh. Don't announce it. Seriously. If you throw a party I will climb out the window.",
			"New job title. Now I watch THEIR taverns. This is the best day of my — this is fine. It's fine.",
		},
	},

	cleric = {
		voice = "Warm, unhurried, gently immovable. Says hard things kindly.",
		interview = {
			approach = "Peace on this house. I heard there are people here who get hurt. That's usually where I'm needed.",
			nodes = {
				{
					id = "home",
					prompt = "Do your people come home?",
					options = {
						{ text = "Not always whole.", reply = "Then we'll mend them together.", flag = "told_truth" },
						{
							text = "Always, no exceptions.",
							reply = "We both know better. But I hear the wish inside the lie.",
							flag = "lied_interview",
						},
					},
				},
				{
					id = "bribe",
					prompt = "(You could sweeten the offer with gold...)",
					options = {
						{ text = "Offer extra gold.", reply = "Put it away, friend. Gold doesn't sway me — it just tells me you think it should." },
						{ text = "Keep it plain.", reply = "Good. Plain travels furthest." },
					},
				},
			},
			ask = {
				want = "To be where the mending is needed. Payment is between you and your conscience.",
				worked = "Chapels, sickbeds, one very stubborn shrine. The work is the same everywhere: people.",
				know = "Idle hands trouble me. Wounded ones, oddly, give me purpose.",
			},
			sign = "Then I'll fetch my things. Keep the kettle on — healing is nine parts tea.",
			walkAway = "I'll be near, should anyone need mending. They usually do.",
		},
		registers = {
			signed = {
				"Your medicine shelf is a superstition and a prayer. We'll fix that.",
				"Tell the fighters: pain hidden is pain doubled.",
			},
			trusted = {
				"The Barbarian pretends his armor squeaks so he has an excuse to visit me. I oil it slowly.",
				"You carry this place on your back, you know. Even owners need tending.",
			},
			devoted = {
				"The Barbarian asked me to check on you. He worries. Don't tell him I told you.",
				"I've served chapels colder than your tavern hearth. I know which one felt more like faith.",
			},
			devoted_lied = "That kind lie you told me the first day — 'always, no exceptions.' You've spent every day since trying to make it true. That's better than honesty. That's penance.",
		},
		quirkLines = {
			fired = "Bring them to me. — No, it's alright. Truly. This is the part I'm *for*.",
		},
		raven = {
			trigger = "cursed_ground",
			text = "Sister Maren says the ground here is wrong. She can cleanse it — slow — or ward the party and push through — fast.",
			options = {
				{ text = "Cleanse it.", effect = "cleanse" },
				{ text = "Push through.", effect = "safe" },
			},
		},
		returns = {
			Triumph = "Not one scratch to mend. I confess I feel slightly unemployed. It's wonderful.",
			Success = "All home. Bruises only. Bruises I can love.",
			Setback = "They'll heal. Sit with them tonight, though. That part's your medicine to give, not mine.",
			Disaster = "I need bandages, boiled water, and for you to not blame yourself louder than I can work. Go.",
		},
		tierUps = {
			"A priest's blessing carries further, they say. We'll test the range together.",
			"High Cleric. Hm. The title fits strangely — like new boots. The work, though — the work fits perfectly.",
		},
	},

	barbarian = {
		voice = "Enormous man, small voice. Comically specific fears. The tavern's heart.",
		interview = {
			approach = "I— hello. I'm told I look intimidating. Please don't be intimidated. It's mostly shoulders.",
			nodes = {
				{
					id = "armor",
					prompt = "How thick is your armor? The armor you give people. Numerically.",
					options = {
						{ text = "Thick enough. We maintain it.", reply = "Maintained! Maintenance is love. Measurable love." },
						{ text = "Thickest in the realm!", reply = "REALLY? ...Really?", flag = "lied_interview" },
					},
				},
				{
					id = "honesty",
					prompt = "Do your quests have... surprises? I don't love surprises. Surprises are just ambushes with better publicity.",
					options = {
						{
							text = "Sometimes it goes wrong.",
							reply = "...Okay. Okay okay okay. But you TELL people when it might. That's all I ask. Warnings.",
							flag = "told_truth",
						},
						{ text = "Never! Totally safe!", reply = "REALLY? Wonderful! ...Really?", flag = "lied_interview" },
					},
				},
			},
			ask = {
				want = "Good armor is a hug you can wear into a fight. I want the hug.",
				worked = "Several warbands. They kept CHEERING before charges. Why would you WARN the danger?",
				know = "Rate your spiders. Tavern spiders. One to ten.",
			},
			sign = "I'll do it. I'll — yes. Signing. Look at me signing. Very brave already.",
			walkAway = "I'm going to go stand near the door. Not LEAVE. Just... near it.",
		},
		registers = {
			signed = {
				"I checked the cellar for monsters. None. I'll check again tomorrow. Vigilance.",
				"Is the big sword mandatory, or can I hold a medium sword with big confidence?",
			},
			trusted = {
				"Sister Maren oils my armor when it squeaks. Don't tell her I loosen it on purpose.",
				"You know what's braver than not being scared? Going anyway. I read that on a tapestry. Gripping tapestry.",
			},
			devoted = {
				"I'm still scared. Every job. But now it's — smaller than the other thing. The us thing. Team. I mean team.",
				"If anything ever comes for this tavern, it will have to go through me. It WILL get through me, but SLOWLY.",
			},
		},
		quirkLines = {
			fired = "A stranger wants to talk to me privately about my FUTURE? Absolutely not. Goodbye. GOODBYE.",
		},
		raven = {
			trigger = "fear",
			text = "Grunwald's frozen at the cave mouth. The party can talk him through it, or you can send word: 'come home, no shame.'",
			options = {
				{ text = "Talk him through.", effect = "widen", flagSet = "cave_moment" },
				{
					text = "Call him home.",
					effect = "safe",
					loyaltyTick = true,
					reply = "You said no shame. There wasn't any. There WAS relief.",
				},
			},
		},
		returns = {
			Triumph = "I did a BRAVERY. An accidental one, but it COUNTS.",
			Success = "Nobody died and I only screamed tactically.",
			Setback = "The bandits were... taller than advertised. Boss, we need to talk about the advertising.",
			Disaster = "...I ran. I got them out, but I ran first. Sister Maren says that's the same thing as brave. Is it? Don't answer fast.",
		},
		tierUps = {
			"'Reluctant.' An upgrade from 'Nervous.' The bards will sing of my mild improvement!",
			"Remember the cave? I go FIRST now. WHO IS THIS MAN. It's me. It's still me, just — forward.",
		},
		memoryHooks = {
			cave_moment = "You didn't leave me at that cave. So I stopped leaving me there too.",
		},
	},

	gourmet_knight = {
		voice = "Grand chivalric diction applied entirely to food.",
		interview = {
			approach = "I have ridden far, and I smell... rosemary? A house of culture. Proceed.",
			nodes = {
				{
					id = "bread",
					prompt = "Your guild's honor — unstained? And your bread — think carefully — crusty or soft?",
					options = {
						{ text = "Honor's intact. Bread's honest.", reply = "Honest bread. The foundation of all chivalry." },
						{ text = "Finest bread in six counties!", reply = "SIX counties. I shall verify. I always verify.", flag = "lied_interview" },
					},
				},
				{
					id = "honesty",
					prompt = "Has this guild ever broken its sworn word?",
					options = {
						{
							text = "Tell the truth, whatever the record shows.",
							reply = "So the ledger says, and so say you. Alignment! The rarest seasoning.",
							flag = "told_truth",
						},
						{ text = "Never. Not once. Ever.", reply = "Odd. The ledgers sing a different recipe.", flag = "lied_interview" },
					},
				},
			},
			ask = {
				want = "Honor upheld, appetite respected. In that order. Usually.",
				worked = "In the siege of Marrowgate I ate my own boot. Braised, mind you. Standards even in despair.",
				know = "An army marches on its stomach. A knight *gallops* on his.",
			},
			sign = "My sword, my honor, and my appetite — all three are yours. Feed at least two.",
			walkAway = "I shall dine elsewhere tonight. The rosemary, however, will haunt me.",
		},
		registers = {
			signed = {
				"The stew is honest work. Honest work with insufficient thyme.",
				"I patrol the kitchen nightly. For security. Security reasons.",
			},
			trusted = {
				"In the siege of Marrowgate I ate my own boot. Braised, mind you. Standards even in despair.",
				"Your table is becoming known in three counties. I may have... evangelized.",
			},
			devoted = {
				"Many halls have offered me feasts. Only this one offered me a *seat that was mine.* The distinction is everything.",
				"When I first came, I stayed for the bread. I remain for the baker. All of you. You're all the baker. You understand.",
			},
		},
		quirkLines = {
			fired = "A NEW OVEN. Sound the horns. Sound them DELICIOUSLY.",
		},
		raven = {
			trigger = "negotiate",
			text = "Sir Alduin reports the bandit chief has offered parley... over dinner. He requests permission to negotiate. And attend. Mostly attend.",
			options = {
				{ text = "Parley.", effect = "presence_path" },
				{ text = "Refuse.", effect = "safe", reply = "He fights better hungry anyway. Angrier." },
			},
		},
		returns = {
			Triumph = "Victory! And the roadside inn en route — magnificent. Two triumphs, honestly.",
			Success = "The quest is done and the rations were adequate. I have notes. Seventeen notes.",
			Setback = "We were ambushed at luncheon. LUNCHEON. Some men have no code whatsoever.",
			Disaster = "I have no appetite tonight. ...Yes. It was that bad.",
		},
		tierUps = {
			"Feast Knight! At last, a title one can pronounce while chewing.",
			"They say my presence now draws diners to the hall. A holy calling. The HOLIEST calling.",
		},
	},
}

-- ============================================================
-- Patron ambient chatter by act (script doc §6) — Slice 1 ships Acts I–II.
-- ============================================================
Dialogue.PatronChatter = {
	act1 = {
		"Never heard of this place. The stew's the audition, then.",
		"Is the fire always this smoky, or is that ambiance?",
		"Someone said this used to be the old man's hall. Shame what happened. Or — nobody actually knows what happened.",
		"One hero on the books? Bold to call it a 'guild,' but I admire arithmetic optimism.",
	},
	act2 = {
		"The valley's talking about the crew that cleared the crypt road.",
		"That's the healer who wouldn't take the Baron's bribe. In THIS tavern. Sitting RIGHT there.",
		"My cousin's caravan got through Thornwood untouched. First time in years. Guess whose work.",
		"Heard the big fellow screamed the whole job and finished it anyway. That's a new kind of brave and I'm for it.",
	},
}

-- ============================================================
-- Floor barks (script doc §8)
-- ============================================================
Dialogue.Floor = {
	orders = {
		"Stew, and don't be shy with the bread.",
		"Whatever the big nervous fellow's having. He seems trustworthy about food.",
		"Ale. The honest kind, not the 'house special' kind.",
		"Bread and whatever's hot. Long road behind me.",
	},
	fastService = "Quick hands! You run the guild AND the floor? Marry my daughter. Joke. Half a joke.",
	eavesdropQuirk = "…see the one at the bar? %s. Make of that what you will.",
	eavesdropQuest = "…crypt road's quiet but the miller swears the well whispers. Wells don't whisper. Usually.",
	eavesdropFlavor = {
		"…the Bramble Boys robbed a cheese cart. Just the cheese. Left the gold. Nobody understands them.",
		"…old Redcap's boys are pushing farther up the coach road every week, mark me.",
		"…a gray figure was writing names in a ledger by the docks. Gave me a chill.",
	},
}

-- ============================================================
-- Story NPCs & system barks (script doc §9–10)
-- ============================================================
Dialogue.UnclesLetter = table.concat({
	"If you're reading this, the hall is yours, and I'm somewhere the ravens don't fly. Three things.",
	"One: the fire never goes fully out — there's a trick to the banking, ask nobody, figure it out, it's good for you.",
	"Two: heroes don't follow gold, whatever they say at the bar. They follow how you treat the ones who cost you nothing.",
	"Three: when a man from the old rival hall comes asking — and he will — count the spoons after.",
	"The rest, you'll write yourself. It's a good hall. It was never about the ale.",
	"— Your uncle",
}, "\n\n")

Dialogue.System = {
	welcomeBack = "The fire held. The till filled. And travelers are asking after the owner…",
	welcomeBackBig = "Word of your hall traveled while you slept. So did the coin.",
	tierUpFrame = "Raise your cups! The hall marks one of its own — and the round is on the house!",
	brawlWarning = "Oi — table four's arguing about whose guild is better. Yours or yours. Both are yours. They're too drunk to know.",
	brawlResolved = "Broken up with WORDS? In THIS economy?",
}

-- ============================================================
-- Shared raven pools (script doc §7 / quest tables §4.4)
-- ============================================================
Dialogue.NeutralAutoResolutions = {
	"No word came, so %s chose the cautious road. The party continues.",
	"The moment passed. %s shrugged and kept to the plan.",
	"The ravens found the window shut. %s made the safe call and grumbled about it.",
}

-- Beat narration fragments for the return report (spec §4: computed, then narrated).
Dialogue.BeatNarration = {
	APPROACH = {
		won = "The approach went clean.",
		lost = "The approach went loud — a bad start.",
	},
	COMPLICATION = {
		won = "The complication was handled before it grew teeth.",
		lost = "The complication grew teeth.",
	},
	CLIMAX = {
		won = "When it counted, the party held.",
		lost = "When it counted, it came apart.",
	},
}

function Dialogue.forHero(archetype)
	return Dialogue.Heroes[archetype]
end

return Dialogue
