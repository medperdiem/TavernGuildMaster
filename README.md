# Adventurer Tavern — Slice 1 (MVP)

A Roblox tavern-management and hero-recruiting game. You inherit a shabby tavern that
doubles as an adventurers' guild: heroes wander in as patrons, you learn what each one
values, win them over, and send them on quests — while the tavern hums around you.

This repository contains the **full Slice 1 implementation in Luau** (managed with
[Rojo](https://rojo.space)), generated from the design documents in `Documentation/`.

| Doc | What it is |
|---|---|
| `Documentation/adventurer-tavern-design.md` | Game design document (v1.0) |
| `Documentation/adventurer-tavern-spec-slice1.md` | The buildable MVP spec this code implements |
| `Documentation/adventurer-tavern-scripts.md` | All scripted dialogue (→ `src/server/Data/Dialogue.luau`) |
| `Documentation/adventurer-tavern-quests.md` | Procedural quest tables (→ `src/server/Data/QuestTables.luau`) |
| `Documentation/adventurer-tavern-art-and-assets.md` | Builder's handbook for the asset pass |
| `Documentation/adventurer-tavern-next-steps.md` | Execution path |

---

## What's implemented (Slice 1 scope, spec §1)

- **Tavern shell** — built procedurally from Parts by `TavernBuilder.luau` at server start:
  hearth (fire particles + light), bar with two prospect seats, lit job board, six patron
  tables, hero fireside spots, decor slot anchors (`Slot_Wall_01`…) for the Slice 2 decor
  system, warm zone lighting. Swap pieces for vetted Creator Store meshes later without
  touching systems (see **Asset pass**, below).
- **Recruit queue + interviews** — weighted prospect rolls, seat expiry timers, fully
  choice-based interviews with honesty checks, `{told_truth}`/`{lied_interview}` memory
  flags, suspicious signings, and the ask-phase ("What do you want?" / "Where have you
  worked?" / "Anything I should know?").
- **Thornwood quest assembler** — VERB + SUBJECT + ANTAGONIST + LOCATION + 0–1 TWISTS,
  difficulty/reward math, demand hints, job board with refresh timer.
- **Party picker with live odds band** (Risky / Even / Favored) via supply-vs-demand.
- **Encounter-beat resolution** — APPROACH → COMPLICATION(s) → CLIMAX on the four supply
  axes (MIGHT/GUILE/PRESENCE/WARDING), d6 per beat, full outcome ladder
  (Triumph/Success/Setback/Disaster), injuries, loyalty swings, narrated return reports.
- **Mid-quest ravens** — fired at fixed fractions of quest duration; character-moment
  ravens (per-hero triggers), twist-reveal ravens, risk forks per verb; 90-second expiry
  with neutral auto-resolutions; login catch-up for quests that finished offline.
- **Floor tasks** — seated patrons (no pathfinding, by design) with serve orders and
  eavesdrop whispers that leak queue prospects' quirk categories; act-based ambient chatter.
- **Offline earnings + welcome-back screen** — capped reduced-rate accrual, offline quest
  resolution in the haul, disabled doubler slot (no store in Slice 1).
- **The scripted first hour (FTUE)** — uncle's letter → scripted Bram → the wolves job
  that returns as a guaranteed Setback ("Worth it, boss.") → the Cleric-vs-Rogue choice →
  the sealed overreach cliffhanger. Implemented as a step counter, per spec.
- **Save/load** — versioned `PlayerData`, UpdateAsync, 60-second autosave, BindToClose
  flush; active quests persist and resolve on next login.
- **Silent economy plumbing** — wages, reputation score, rep-quest daily cap + bonds all
  accrue with no UI, exactly as the spec defers them.
- **All six heroes** — Bram, Perrin, Vex, Sister Maren, Grunwald, Sir Alduin: interviews,
  loyalty registers (signed/trusted/devoted + memory-hook variants), quirks, character
  ravens, quest-return lines, tier-up lines.

**Deliberately out** (per spec §1): PvP/poaching, regions 2–6, staff hires, cosmetics
store, rep-tier UI, personal chains beyond the FTUE prompt, AI dialogue.

## Repository layout

```
default.project.json      Rojo project (maps src/ → Roblox services)
rokit.toml                Toolchain pins (rojo, selene, stylua)
src/
  server/
    GameServer.server.luau   Boot, join/leave, save/load, remotes, main loop
    Systems/                 QuestSystem · HeroSystem · QueueSystem ·
                             EconomySystem · FloorSystem · FTUESystem · TavernBuilder
    Data/                    Constants · Heroes · Dialogue · QuestTables (pure tables)
  shared/                  RemoteNames · SharedTypes
  client/                  Main.client.luau + UI/ (Theme, UI helpers, all 8 screens)
.github/workflows/ci.yml  Lints with selene + builds the .rbxlx on every push
```

---

## Setting up on your PC

### 1. Install the tools

1. **Roblox Studio** — [create.roblox.com](https://create.roblox.com/) → "Get Studio".
2. **Rokit** (toolchain manager — installs Rojo/Selene/StyLua pinned in `rokit.toml`):
   - **Windows (PowerShell):**
     ```powershell
     Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | Invoke-Expression
     ```
   - **macOS / Linux:**
     ```bash
     curl -fsSL https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
     ```
   Then, in the repo root:
   ```bash
   rokit install
   ```
   (Alternative: install Rojo directly from [rojo.space](https://rojo.space/docs/v7/getting-started/installation/),
   or via `cargo install rojo --version 7.4.4` if you have Rust.)
3. **Rojo Studio plugin** — run `rojo plugin install`, or get "Rojo" from the Studio
   Plugin Marketplace (same version family as the CLI, 7.x).
4. *(Optional)* **VS Code** with the "Rojo" and "Luau Language Server" extensions for
   editing with autocomplete and type checking.

### 2. Run the game

```bash
rojo serve        # from the repo root
```

1. Open Roblox Studio → create a new **Baseplate** place (delete the baseplate later or
   ignore it — the tavern builds itself at origin; you can also delete `SpawnLocation`).
2. Plugins tab → Rojo → **Connect**. The whole project syncs in live.
3. **Game Settings → Security → Enable Studio Access to API Services** (required for
   DataStore saves in Studio).
4. Press **Play**. The uncle's letter appears; Bram is waiting at the bar.

Alternatively, build a standalone place file:

```bash
rojo build -o AdventurerTavern.rbxlx
```
and open it in Studio (CI also produces this artifact on every push).

### 3. Before publishing

- **File → Game Settings → Basic Info** — fill in as you like.
- **Players → Max Players = 1.** Slice 1 is single-player-per-server: the tavern is a
  shared 3D space and tavern-visiting only arrives with PvP in Slice 3.
- Keep **StreamingEnabled** on (already set by the project file).
- Publish **unlisted** first, per `next-steps.md` step 6.

---

## Asset pass (when you want it prettier)

Everything visual is placeholder Parts from `TavernBuilder.luau`, deliberately built to
the layout rules in the art handbook (landmark hierarchy, camera-first dimensions, slot
anchors). To upgrade, follow `Documentation/adventurer-tavern-art-and-assets.md`:

1. In Studio, open the Toolbox and work through the **starter shopping list** (§8):
   one medieval props pack · tankard/food set · lantern set · fireplace parts · rugs ·
   sign board · fence/plant set · stage platform · fire-crackle ambient loop + coin/door/
   cheer one-shots.
2. **Vet every asset** per §3: insert into an empty place, delete every Script/
   LocalScript/ModuleScript, check for hidden extras, fix scale, then copy in.
3. Replace or decorate the generated models (`Workspace.Tavern.*`) — keep the named
   anchor parts (`ProspectSeat1/2`, `PatronSeat1–6`, `HeroSpot1–6`, `Slot_*`) where they
   are (or move them with their furniture): all systems find the world through those names.
4. NPC placeholders (`TavernBuilder.makeNpc`) can be swapped for rigs/meshes later —
   systems only need `PrimaryPart` and the attached ProximityPrompt.

## Tuning

Every tunable number lives in **one file**: `src/server/Data/Constants.luau` (spec §6).
Quest pacing, economy costs, loyalty ticks, patron cadence — change there, nowhere else.

## Verification (Definition of Done, spec §9)

A new player can: play the scripted first hour → sign 3+ heroes through real interviews →
run 10+ procedurally distinct Thornwood quests with ravens → get a hero injured and
healed → discover a quirk through play → log off, return, and get a welcome-back haul
including an offline-resolved quest → fill a session with serve/eavesdrop between ravens.
Zero Robux surface. Save survives rejoin.

**The one metric that matters:** do playtesters mention a hero *by name* afterwards.

## CI

`.github/workflows/ci.yml` runs on every push: Selene lint (Luau, Roblox std) and a
`rojo build`, uploading `AdventurerTavern.rbxlx` as a downloadable artifact — so you can
grab a ready-to-open place file from the Actions tab without installing anything.
