--!nonstrict
-- TavernBuilder.luau — builds the tavern interior from Parts at server start.
-- Art handbook §1: parts + materials + lighting ARE the art. This is the placeholder
-- shell; swap pieces for vetted Creator Store meshes later without touching systems.
-- Landmark hierarchy (§5): HEARTH → BAR → JOB BOARD → DOOR, on a circulation loop.
-- Camera-first: 10-stud doorway, 18-stud ceiling. Slot anchors placed NOW (§5).

local TavernBuilder = {}

local WOOD = Color3.fromRGB(92, 62, 38)
local WOOD_DARK = Color3.fromRGB(66, 44, 27)
local STONE = Color3.fromRGB(120, 116, 110)
local FLAME = Color3.fromRGB(255, 148, 54)

local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in pairs(props) do
		p[key] = value
	end
	return p
end

local function model(name, parent)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

local function lantern(position, parent, brightness)
	local m = model("Lantern", parent)
	local body = part({
		Name = "Body",
		Size = Vector3.new(0.8, 1.2, 0.8),
		Position = position,
		Material = Enum.Material.Neon,
		Color = FLAME,
		CanCollide = false,
		Parent = m,
	})
	local light = Instance.new("PointLight")
	light.Color = FLAME
	light.Brightness = brightness or 1.2
	light.Range = 14
	light.Parent = body
	return m
end

local function table_(name, position, parent)
	local m = model(name, parent)
	part({
		Name = "Top",
		Size = Vector3.new(6, 0.6, 6),
		Position = position + Vector3.new(0, 3, 0),
		Material = Enum.Material.WoodPlanks,
		Color = WOOD,
		Parent = m,
	})
	part({
		Name = "Leg",
		Size = Vector3.new(1, 3, 1),
		Position = position + Vector3.new(0, 1.5, 0),
		Material = Enum.Material.Wood,
		Color = WOOD_DARK,
		Parent = m,
	})
	lantern(position + Vector3.new(0, 3.9, 0), m, 0.8)
	return m
end

local function stool(name, position, parent)
	local m = model(name, parent)
	local seat = part({
		Name = "Seat",
		Size = Vector3.new(2, 0.5, 2),
		Position = position + Vector3.new(0, 1.75, 0),
		Material = Enum.Material.Wood,
		Color = WOOD_DARK,
		Parent = m,
	})
	part({
		Name = "Leg",
		Size = Vector3.new(0.8, 1.5, 0.8),
		Position = position + Vector3.new(0, 0.75, 0),
		Material = Enum.Material.Wood,
		Color = WOOD_DARK,
		CanCollide = false,
		Parent = m,
	})
	m.PrimaryPart = seat
	return m
end

-- Simple blocky NPC placeholder (prospects, patrons, idle heroes). Swap for rigs later.
function TavernBuilder.makeNpc(name, color, position, parent)
	local m = model(name, parent)
	local torso = part({
		Name = "Torso",
		Size = Vector3.new(2, 2.4, 1),
		Position = position + Vector3.new(0, 3.2, 0),
		Material = Enum.Material.Fabric,
		Color = color,
		CanCollide = false,
		Parent = m,
	})
	part({
		Name = "Head",
		Size = Vector3.new(1.3, 1.3, 1.3),
		Position = position + Vector3.new(0, 5.1, 0),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(233, 195, 160),
		CanCollide = false,
		Parent = m,
	})
	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.fromOffset(160, 28)
	tag.StudsOffset = Vector3.new(0, 2.4, 0)
	tag.AlwaysOnTop = true
	tag.Parent = torso
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.TextScaled = true
	label.Font = Enum.Font.Merriweather
	label.Parent = tag
	m.PrimaryPart = torso
	return m
end

-- Build everything. Returns a table of named anchors systems hang off.
function TavernBuilder.build()
	local workspaceService = game:GetService("Workspace")
	local existing = workspaceService:FindFirstChild("Tavern")
	if existing then
		existing:Destroy()
	end
	local tavern = model("Tavern", workspaceService)

	-- Shell: 64 × 48 floor, 18-stud ceiling, 10-stud door gap on the south wall.
	part({
		Name = "Floor",
		Size = Vector3.new(64, 1, 48),
		Position = Vector3.new(0, -0.5, 0),
		Material = Enum.Material.WoodPlanks,
		Color = WOOD_DARK,
		Parent = tavern,
	})
	part({
		Name = "Ceiling",
		Size = Vector3.new(64, 1, 48),
		Position = Vector3.new(0, 18.5, 0),
		Material = Enum.Material.Wood,
		Color = WOOD_DARK,
		Parent = tavern,
	})
	part({ Name = "WallN", Size = Vector3.new(64, 18, 1), Position = Vector3.new(0, 9, -23.5), Material = Enum.Material.Brick, Color = STONE, Parent = tavern })
	part({ Name = "WallE", Size = Vector3.new(1, 18, 48), Position = Vector3.new(31.5, 9, 0), Material = Enum.Material.Brick, Color = STONE, Parent = tavern })
	part({ Name = "WallW", Size = Vector3.new(1, 18, 48), Position = Vector3.new(-31.5, 9, 0), Material = Enum.Material.Brick, Color = STONE, Parent = tavern })
	-- South wall in two segments leaving the 10-stud doorway.
	part({ Name = "WallS1", Size = Vector3.new(27, 18, 1), Position = Vector3.new(-18.5, 9, 23.5), Material = Enum.Material.Brick, Color = STONE, Parent = tavern })
	part({ Name = "WallS2", Size = Vector3.new(27, 18, 1), Position = Vector3.new(18.5, 9, 23.5), Material = Enum.Material.Brick, Color = STONE, Parent = tavern })

	-- HEARTH (north wall center): the heart, biggest visual mass, always animated.
	local hearth = model("Hearth", tavern)
	part({
		Name = "Mantle",
		Size = Vector3.new(14, 10, 3),
		Position = Vector3.new(0, 5, -21.5),
		Material = Enum.Material.Slate,
		Color = STONE,
		Parent = hearth,
	})
	local firebox = part({
		Name = "Firebox",
		Size = Vector3.new(8, 5, 2),
		Position = Vector3.new(0, 2.5, -21),
		Material = Enum.Material.Neon,
		Color = FLAME,
		CanCollide = false,
		Parent = hearth,
	})
	local fire = Instance.new("ParticleEmitter") -- embers recipe (art handbook §7)
	fire.Texture = "rbxasset://textures/particles/fire_main.dds"
	fire.Rate = 18
	fire.Lifetime = NumberRange.new(0.8, 1.4)
	fire.Speed = NumberRange.new(2, 4)
	fire.Color = ColorSequence.new(FLAME, Color3.fromRGB(120, 40, 10))
	fire.Size = NumberSequence.new(1.6, 0.4)
	fire.Parent = firebox
	local fireLight = Instance.new("PointLight")
	fireLight.Color = FLAME
	fireLight.Brightness = 2.5
	fireLight.Range = 26
	fireLight.Parent = firebox

	-- BAR (east wall): the queue's home — prospects sit here.
	local bar = model("Bar", tavern)
	part({
		Name = "Counter",
		Size = Vector3.new(3, 3.6, 22),
		Position = Vector3.new(27, 1.8, 0),
		Material = Enum.Material.WoodPlanks,
		Color = WOOD,
		Parent = bar,
	})
	lantern(Vector3.new(27, 4.5, -8), bar, 1.0)
	lantern(Vector3.new(27, 4.5, 8), bar, 1.0)
	local prospectSeats = {}
	for i = 1, 2 do
		local z = (i == 1) and -5 or 5
		local seatModel = stool("ProspectSeat" .. i, Vector3.new(23.5, 0, z), bar)
		prospectSeats[i] = seatModel
	end

	-- JOB BOARD (west wall): distinct silhouette, lit, cool candle-white zone (§5).
	local board = model("JobBoard", tavern)
	local boardPart = part({
		Name = "Board",
		Size = Vector3.new(1, 8, 12),
		Position = Vector3.new(-30.5, 6, -6),
		Material = Enum.Material.Wood,
		Color = WOOD,
		Parent = board,
	})
	local boardLight = Instance.new("PointLight")
	boardLight.Color = Color3.fromRGB(235, 235, 210)
	boardLight.Brightness = 1.4
	boardLight.Range = 16
	boardLight.Parent = boardPart
	local boardPrompt = Instance.new("ProximityPrompt")
	boardPrompt.Name = "BoardPrompt"
	boardPrompt.ActionText = "Read the Job Board"
	boardPrompt.ObjectText = "Job Board"
	boardPrompt.MaxActivationDistance = 12
	boardPrompt.RequiresLineOfSight = false
	boardPrompt.Parent = boardPart

	-- Patron tables scattered along the circulation loop (board → bar → hearth).
	local patronSeats = {}
	local tablePositions = {
		Vector3.new(-14, 0, 8),
		Vector3.new(-2, 0, 12),
		Vector3.new(12, 0, 8),
		Vector3.new(-14, 0, -8),
		Vector3.new(12, 0, -8),
		Vector3.new(-2, 0, -12),
	}
	for i, position in ipairs(tablePositions) do
		table_("Table" .. i, position, tavern)
		patronSeats[i] = stool("PatronSeat" .. i, position + Vector3.new(4, 0, 0), tavern)
	end

	-- Hero fireside spots: where idle/resting heroes stand for fireside chats.
	local heroSpots = {}
	for i = 1, 6 do
		local spot = part({
			Name = "HeroSpot" .. i,
			Size = Vector3.new(2, 0.2, 2),
			Position = Vector3.new(-10 + (i - 1) * 4, 0.1, -17),
			Transparency = 1,
			CanCollide = false,
			Parent = tavern,
		})
		heroSpots[i] = spot
	end

	-- Slot anchors for the Slice 2 decor system — placed NOW (art handbook §5 ⚖).
	local slots = model("DecorSlots", tavern)
	local slotDefs = {
		{ "Slot_Wall_01", Vector3.new(-20, 8, -23) },
		{ "Slot_Wall_02", Vector3.new(20, 8, -23) },
		{ "Slot_Wall_03", Vector3.new(-30.8, 8, 10) },
		{ "Slot_Wall_04", Vector3.new(30.8, 8, -12) },
		{ "Slot_Floor_01", Vector3.new(-24, 0.2, 16) },
		{ "Slot_Floor_02", Vector3.new(24, 0.2, 16) },
		{ "Slot_Stage_01", Vector3.new(-22, 0.2, -14) }, -- Perrin's future stage
		{ "Slot_Garden_01", Vector3.new(26, 0.2, 19) }, -- Nettle's future garden
	}
	for _, def in ipairs(slotDefs) do
		local slot = part({
			Name = def[1],
			Size = Vector3.new(2, 0.4, 2),
			Position = def[2],
			Transparency = 1,
			CanCollide = false,
			Parent = slots,
		})
		slot:SetAttribute("SlotType", def[1]:match("Slot_(%a+)"))
	end

	-- Spawn just inside the door, facing the hearth.
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = Vector3.new(0, 0.5, 19)
	spawn.CFrame = CFrame.lookAt(Vector3.new(0, 0.5, 19), Vector3.new(0, 0.5, -21))
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Transparency = 1
	spawn.Parent = tavern

	return {
		tavern = tavern,
		boardPrompt = boardPrompt,
		prospectSeats = prospectSeats,
		patronSeats = patronSeats,
		heroSpots = heroSpots,
	}
end

return TavernBuilder
