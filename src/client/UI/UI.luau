--!nonstrict
-- UI.luau — tiny declarative helpers over Instance.new for all screens.

local Theme = require(script.Parent:WaitForChild("Theme"))

local UI = {}

function UI.apply(instance, props, children)
	for key, value in pairs(props or {}) do
		instance[key] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = instance
	end
	return instance
end

function UI.corner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or Theme.Corner
	corner.Parent = parent
	return corner
end

function UI.padding(parent, all)
	local pad = Instance.new("UIPadding")
	local u = UDim.new(0, all)
	pad.PaddingTop, pad.PaddingBottom, pad.PaddingLeft, pad.PaddingRight = u, u, u, u
	pad.Parent = parent
	return pad
end

function UI.vlist(parent, gap)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, gap or 6)
	layout.Parent = parent
	return layout
end

function UI.frame(props, children)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Theme.Panel
	frame.BorderSizePixel = 0
	return UI.apply(frame, props, children)
end

function UI.scroll(props, children)
	local frame = Instance.new("ScrollingFrame")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ScrollBarThickness = 6
	frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	frame.CanvasSize = UDim2.new()
	return UI.apply(frame, props, children)
end

function UI.label(props, children)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Theme.Font
	label.TextColor3 = Theme.Text
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextSize = 18
	return UI.apply(label, props, children)
end

function UI.button(props, onClick, children)
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Theme.PanelLight
	button.BorderSizePixel = 0
	button.Font = Theme.FontBold
	button.TextColor3 = Theme.Text
	button.TextWrapped = true
	button.TextSize = 18
	button.AutoButtonColor = true
	UI.apply(button, props, children)
	UI.corner(button)
	if onClick then
		button.Activated:Connect(onClick)
	end
	return button
end

-- Modal panel centered on screen; returns (overlay, panel).
function UI.modal(parent, size, name)
	local overlay = UI.frame({
		Name = name or "Modal",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		Visible = false,
		ZIndex = 5,
	})
	overlay.Parent = parent
	local panel = UI.frame({
		Size = size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Panel,
		ZIndex = 6,
	})
	UI.corner(panel, UDim.new(0, 14))
	UI.padding(panel, 14)
	panel.Parent = overlay
	return overlay, panel
end

return UI
