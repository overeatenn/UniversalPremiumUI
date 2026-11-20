-- Reusable UI components
local TweenService = game:GetService("TweenService")
local Components = {}
local Theme, State

function Components.Init(theme, state)
	Theme = theme
	State = state
end

function Components.New(class, props)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do i[k] = v end
	return i
end

function Components.Tween(obj, goals, t, style, dir)
	local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, goals)
	tw:Play()
	return tw
end

function Components.Shadow(parent, size, alpha)
	return Components.New("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.new(0,0,0),
		ImageTransparency = alpha or 0.55,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49,49,450,450),
		Size = UDim2.new(1, size*2, 1, size*2),
		Position = UDim2.fromOffset(-size, -size),
		ZIndex = 0,
		Parent = parent,
	})
end

function Components.Card(parent, size, pos)
	local f = Components.New("Frame", {
		Size = size,
		Position = pos or UDim2.fromScale(0,0),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = Theme.Glass,
		BorderSizePixel = 0,
		Parent = parent,
	})
	Components.New("UICorner", {CornerRadius = UDim.new(0, 12), Parent = f})
	Components.New("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.55, Parent = f})
	Components.Shadow(f, 14, 0.58)
	return f
end

function Components.Toggle(parent, size, pos, initial, onChange)
	local track = Components.New("Frame", {
		Size = size or UDim2.fromOffset(36, 20),
		Position = pos or UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = initial and Theme.Accent or Theme.Border,
		BorderSizePixel = 0,
		Parent = parent,
	})
	Components.New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
	local knob = Components.New("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = initial and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
		Parent = track,
	})
	Components.New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

	local function set(on)
		Components.Tween(track, {BackgroundColor3 = on and Theme.Accent or Theme.Border}, 0.15)
		Components.Tween(knob, {Position = on and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)}, 0.15, Enum.EasingStyle.Back)
	end

	local hit = Components.New("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Parent = track,
	})
	hit.MouseButton1Click:Connect(function()
		local new = not (track.BackgroundColor3 == Theme.Accent)
		set(new)
		if onChange then onChange(new) end
	end)
	return {Set = set, Track = track}
end

function Components.Notify(host, text, color)
	local pill = Components.New("Frame", {
		Size = UDim2.fromOffset(0, 32),
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Parent = host,
	})
	Components.New("UICorner", {CornerRadius = UDim.new(0, 10), Parent = pill})
	Components.New("UIStroke", {Color = color or Theme.Accent, Thickness = 1, Transparency = 0.35, Parent = pill})
	local lbl = Components.New("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Parent = pill,
	})
	Components.Tween(pill, {Size = UDim2.fromOffset(math.clamp(#text * 7 + 28, 120, 280), 32)}, 0.22, Enum.EasingStyle.Back)
	task.delay(2.1, function()
		Components.Tween(pill, {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 32)}, 0.18).Completed:Connect(function()
			pill:Destroy()
		end)
		lbl.TextTransparency = 1
	end)
end

return Components
