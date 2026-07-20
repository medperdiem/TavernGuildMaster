# Adventurer Tavern — Art, Assets & Layout Handbook
*The builder's companion: modeling without being a modeler, sourcing free assets safely, layout principles, visual progression, and the cosmetics production line. Written for a first-time Studio builder shipping this specific game.*

---

## 1. Philosophy: Build With Parts, Borrow Meshes, Model Last

You never need Blender for this game. The order of tools, cheapest first:
1. **Parts** (blocks, cylinders, wedges, spheres) — 80% of a cozy tavern is boxes with good materials and lighting. Tables, bar, beams, shelves, hearth: all parts.
2. **Borrowed MeshParts** from the Creator Store — the detailed 20%: mugs, food, barrels, weapons, chairs with character.
3. **Unions (CSG)** — sparingly, for one-off shapes like an arched doorway. Unions cost performance and misbehave when re-edited; if you're unioning more than a few pieces, look for a mesh instead.
4. **Actual modeling** — only if the game succeeds and a signature asset demands it. Not before.

The skill that replaces modeling is **composition**: proportion, repetition, and lighting. A plain block table with a lantern, two mugs, and warm light reads "tavern" better than a detailed mesh in flat lighting.

## 2. Minimum Viable Studio Skillset (learn these ten things, skip the rest)

1. Move/Scale/Rotate with **snapping** (1 stud / 15° for structure; 0.1 stud snap for props). Consistent snap = clean builds.
2. **Anchor everything static.** Unanchored decor falls through the world or becomes a physics bill. Select-all → Anchor is a habit, not a step.
3. **Material + Color before detail.** Wood planks, slate, fabric, metal — Roblox materials do enormous lifting. One part, right material, beats five parts in plastic.
4. **Duplicate (Ctrl+D) + nudge** is your production line. Build one perfect table set, duplicate six times, vary the mug positions.
5. **Group into Models** and NAME them (`Table_A`, `Hearth`, `Slot_Wall_03`). Future-you in the Explorer will otherwise drown in "Part".
6. **Pivot points** — set a model's pivot to its floor center so slot-stamping code places it predictably.
7. **Attributes** on models (e.g., `DecorTag = "gold"`, `SlotType = "wall"`) — this is how the decor system reads the world.
8. **PointLight / SpotLight** inside prop models (lantern = neon part + PointLight). Lighting IS the art style.
9. **ParticleEmitter** basics: rate, lifetime, speed, color-over-life. Fire, embers, dust motes, shimmer — the premium look for free.
10. **Collision settings:** CanCollide OFF for small clutter (mugs, plates) so players never trip on props; CollisionFidelity = Box on imported meshes for performance.

Everything else in Studio can be learned when a task demands it.

## 3. Finding Free Assets (and not importing a virus)

**Where:** the Toolbox inside Studio (View → Toolbox) or the Creator Store on the Creator Hub — same marketplace with millions of assets: models, materials, audio, plugins.

**Search craft:**
- Search the *object*, not the vibe: "medieval table", "barrel", "fantasy lantern", "stew bowl" — not "tavern stuff".
- Prefer **asset packs** ("medieval pack", "fantasy props pack") — one creator's pack = consistent style across 20 props, which solves the kitbash-looks-random problem in one download.
- Quality signals: verified creators, high install/favorite counts, recent updates, and clean thumbnails on a neutral background.
- Roblox's own published packs (search creator "Roblox") are always safe and stylistically neutral.

**The vetting ritual (every single asset, no exceptions):**
1. Insert into an EMPTY baseline place first, not your game.
2. In Explorer, expand the model fully. **Delete every Script, LocalScript, and ModuleScript** — your decor needs zero code. This kills essentially all Toolbox malware.
3. Distrust anything whose scripts are obfuscated or that tries to load other assets at runtime (patterns like require-by-ID or loadstring are exactly what the Creator Store's own safety rules restrict — their presence in a "prop" is disqualifying).
4. Check for hidden extras: fire/smoke effects buried inside, absurdly distant welded parts (select the model → F to zoom fit; if the camera flies to orbit, something's hiding far away).
5. Check scale against a spawned dummy character; Toolbox assets arrive at wild sizes. Scale as a whole model, not per-part.
6. THEN copy into your game, into the right folder, named properly.

**Licensing note:** Creator Store assets are licensed for use in your experiences — safe to build and monetize with. Don't re-upload others' assets as your own creations, and be cautious of packs that are obvious rips of copyrighted characters/IP; using those risks your game, not the uploader's.

## 4. Asset Hygiene & Performance Budget

A tavern with six players, patrons, and heroes on phones needs discipline more than optimization tricks:
- **Part budget:** keep the tavern interior in the low thousands of parts. One hero's-worth of clutter detail around the hearth and bar (where cameras linger), restraint elsewhere.
- **Reuse over variety:** twelve identical mugs beat twelve unique mugs — instancing is cheap, uniqueness is not (and visual repetition reads as "a set", which is cozier anyway).
- **Textures:** prefer Roblox materials over custom textures; every custom texture is a download for every player.
- **StreamingEnabled ON** from day one (the village lane in Slice 2 will require it; retrofitting is painful).
- **Lighting:** pick a technology and commit — on mobile-heavy audiences, fancy lighting modes cost frames; test on the worst phone in the house. Bake the mood from many small warm lights, not a few big bright ones.
- **Audio:** one ambient loop (fire crackle + murmur) + a handful of one-shots (coin, door, cheer). Sound is the cheapest immersion per byte in the whole engine.

## 5. Layout Principles (the tavern, then the village)

**Landmark hierarchy.** A player who spawns in should read the room in one camera sweep: HEARTH (the heart, biggest visual mass, always animated by fire) → BAR (the queue's home — prospects sit here) → JOB BOARD (distinct silhouette, lit) → DOOR (where the world comes in). Every system's physical anchor gets one landmark; nothing important lives in a corner.

**The circulation loop.** Lay the floor so walking board → bar → hearth → board is a natural ring with no dead ends. Players patrol loops; they abandon cul-de-sacs. Floor tasks (serving) should scatter along the loop so hosting = walking the ring.

**Camera-first dimensions.** Roblox third-person cameras need generous space: doorways 8+ studs wide, ceilings 16+ studs in main rooms (low ceilings = camera clipping = the #1 beginner-build frustration), furniture spaced so the camera orbits without wall-fighting. Build for the camera, decorate for the eye.

**Interaction spacing.** ProximityPrompts (bar, board, prospects, patrons) need breathing room — keep prompt sources 6+ studs apart so the wrong prompt never steals focus on mobile.

**Zone lighting as signage.** Warm orange = hearth/social, cool candle-white = board/business, soft green-gold = the Witch's garden corner. Players learn zones by color temperature without a single UI label.

**Slot-anchor discipline (ties to the Slice 2 decor system).** Place invisible anchor parts (`Slot_Wall_01`…) NOW, as you build the base tavern — walls, shelf tops, table centers, yard spots. Decor stamping, queue-modifier tags, and visitor-visible status all hang off these ~30 anchors. Retrofitting slots into a finished build is misery; placing them while walls go up is free.

**Village lane (Slice 2 preview):** the lane is a single gentle S-curve (sightlines reveal taverns one by one, not all at once), square at the center with the King's Board as ITS landmark, plots angled slightly toward the walker. Same landmark logic, scaled up: Board → Obelisk → Well.

## 6. Visual Progression of Items & Gear

**The one rule: silhouette stays, surface escalates.** A player must recognize "sword" at every tier and "better sword" at a glance across the room. Tier recipe (applies to gear, decor lines, and hero outfits alike):

| Tier | Surface treatment |
|---|---|
| Common | Base material, muted color |
| Uncommon | Richer material + one accent color |
| Rare | Premium material (polished metal, marble) + subtle glow trim (thin neon inlay) |
| Epic/Seasonal | Emissive accents + a slow ParticleEmitter (drifting motes) |
| Legendary | Full effect identity: colored light source + particles + a sound cue on interaction |

This is the recolor strategy from the design doc turned into a ladder: each tier is minutes of property edits on the SAME asset, and the escalation grammar (material → glow → particles → light+sound) teaches players to price items by eye. Heroes' tier-up outfits follow the identical grammar so a Warmaster reads as "legendary-grade" beside a legendary sword without any new modeling.

## 7. Cosmetics Made Easy: the Production Line

Treat cosmetics as a **variant matrix**, not individual creations:
1. Pick a base asset already in the tavern (chair, lantern, sign, rug, mug).
2. Roll it through the tier recipe above → 4–5 variants per asset in an afternoon.
3. Roll the SET through a season palette (autumn ambers, winter blues, festival golds) → each season multiplies the catalog again.
4. Bundle: five-piece themed sets (one wall, one table, one light, one floor, one flourish) sell and display better than singles, and a set fills a visual zone coherently.

**Pipeline hygiene:** every cosmetic is a Model with `DecorTag`, `Rarity`, and `SetId` attributes, stored in a `DecorCatalog` folder in ServerStorage, named `set_season_item_tier` (`harvest_amber_lantern_rare`). The store UI, slot-stamper, and queue-modifier system all read attributes — add a cosmetic by dropping a model in the folder and adding one line to Decor.lua. If adding an item takes more than ten minutes, the pipeline is broken, not the artist.

**Effect recipes to keep on hand (each is one ParticleEmitter + tuning):**
- *Embers:* few particles, slow rise, orange→transparent, long life.
- *Shimmer:* tiny white sparks, fast fade, spawn on a surface plane.
- *Motes:* dust in a light shaft — slow, drifting, near-transparent. Instant atmosphere.
- *Blue fire:* duplicate the hearth fire, shift color, add a faint blue PointLight. A whole premium fireplace in five minutes.

**Status pieces** (the highest-margin category): tier-up banners, "☆ Champion ☆" nameplates, trophy pedestals for record badges — TextLabels and pedestals, near-zero art cost, maximum visitor visibility. Build these before any elaborate furniture.

## 8. Tavern Starter Shopping List (first Toolbox session)

One medieval/fantasy props PACK (tables, chairs, barrels, crates) · a tankard/food set · lantern + candle set · fireplace or the parts to fake one (stone blocks + fire particles) · a rug or two · sign board · fence/plant set for the yard (the Witch's garden tag needs it) · one stage-ish platform (Minstrel's quirk) · ambient loop: fireplace crackle; one-shots: coin clink, door creak, small cheer. Vet each per §3. Everything else: parts and lighting.

## 9. Beginner Mistakes This Handbook Exists to Prevent

Building rooms to human-architecture scale (build for the camera) · skipping the empty-place vetting step once because "it's just a barrel" · free-placing decor now and inventing slots later · unique-asset-itis instead of variant matrices · big bright lights instead of many small warm ones · unanchored props · detailing corners no camera visits while the hearth — where every screenshot happens — stays plain. When in doubt: fewer assets, better lit.

*End of handbook.*
