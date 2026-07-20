# Adventurer Tavern — Next Steps
*The execution path from here. Ordered by dependency, no timelines — each step begins when the one before it is done, not on a date.*

---

## The Path

**1. Paper test.**
Read Bram's and Korr's interviews aloud to two or three testers (the household counts — they're the target demographic). Watch for the two signals: do they lean in when the hero pushes back, and do they want to meet the next character. Also run the hour-one "limping farmhand" beat on paper. This is the only remaining check on the game's core bet, and it costs nothing. If it fails, revise the scripts before anything else — the systems are fine either way.

**2. Studio setup + Slice 1 build step 1.**
Open Roblox Studio. Kitbash the tavern shell from free Creator Store assets (vet each for hidden Scripts and delete them). Get the DataStore round-trip working: join → gold saves → rejoin → gold restores, with the version field from day one. Deliberately boring — the Studio/Luau learning curve happens on the lowest-stakes step.

**3. Slice 1 build steps 2–3: queue, interviews, quest loop.**
Translate the script doc into Dialogue.lua and the quest tables doc into QuestTables.lua — the content exists, so this is data entry plus UI. The moment the interview screen works, the paper-test material becomes playable; re-test it there.

**4. First playtest gate.**
Once build steps 1–5 run (through ravens), put it in front of the same testers. One metric: do they mention a hero by name when describing the session. Pass → continue. Fail → fix dialogue delivery before building anything more.

**5. Finish Slice 1.**
Floor tasks, offline earnings + welcome-back, the FTUE sequence. Definition of done is in the Slice 1 spec §9. Zero Robux surface at this stage.

**6. Ship unlisted, invite a handful of players.**
Watch the hero-by-name metric and session shape in the wild. Run the spreadsheet pacing pass against real behavior; re-tune Constants.lua as needed (the economy sim verifies any change in seconds).

**7. Slice 2, per its spec.**
Village, King's Board, duels, first monetization. Then Slices 3–5 strictly by their entry gates in the future-enhancements doc — each gate's telemetry is part of the preceding slice's definition of done.

## Parallel / Anytime

- **Art direction sketch** — which decor sets, the tavern's visual identity. Needed before serious kitbashing; a taste exercise, not a design problem.
- **Dialogue pool top-up** — extend each hero's register pools from the seeded 3–5 lines to 8–12, in-voice, during development lulls. Paper-test new material before building it in.

## On-Demand from Claude

- The paper-test pack: Bram + Korr interviews formatted as read-aloud cards with choice options.
- Dialogue.lua and QuestTables.lua generated directly from the docs (makes step 3 copy-paste).
- A hands-on walkthrough of build step 1 in Studio.
- Sim re-runs for any constant change or new product idea (standing rule: anything sold gets sim-checked first).

## Artifact Index

Design: `adventurer-tavern-design.md` · Scripts: `adventurer-tavern-scripts.md` · Quest tables: `adventurer-tavern-quests.md` · Specs: `adventurer-tavern-spec-slice1.md`, `adventurer-tavern-spec-slice2.md` · Future: `adventurer-tavern-future-slices.md` · Simulations: `economy_sim.py`, `village_sim.py`, `duel_sim.py` (+ `economy_report.txt/.png`) · This file.

## The One Warning

The design phase is complete. From here, additional planning is a comfortable substitute for opening Studio — resist it. The next real progress is a tester leaning in when Korr says "I check. I always check."

*End of next steps.*
