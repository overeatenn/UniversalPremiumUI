-- Components v4.2 — larger controls, consistent system
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
		ImageTransparency = alpha or 0.5,
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
	Components.New("UICorner", {CornerRadius = UDim.new(0, Theme.Radius), Parent = f})
	Components.New("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.45, Parent = f})
	Components.Shadow(f, 16, 0.52)
	return f
end

function Components.Toggle(parent, size, pos, initial, onChange)
	local trackW, trackH = 42, 24
	if size then trackW = size.X.Offset trackH = size.Y.Offset end
	local track = Components.New("Frame", {
		Size = UDim2.fromOffset(trackW, trackH),
		Position = pos or UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = initial and Theme.Accent or Theme.Border,
		BorderSizePixel = 0,
		Parent = parent,
	})
	Components.New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
	local knobSize = trackH - 6
	local knob = Components.New("Frame", {
		Size = UDim2.fromOffset(knobSize, knobSize),
		Position = initial and UDim2.fromOffset(trackW - knobSize - 3, 3) or UDim2.fromOffset(3, 3),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
		Parent = track,
	})
	Components.New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

	local function set(on)
		Components.Tween(track, {BackgroundColor3 = on and Theme.Accent or Theme.Border}, 0.16)
		Components.Tween(knob, {
			Position = on and UDim2.fromOffset(trackW - knobSize - 3, 3) or UDim2.fromOffset(3, 3)
		}, 0.16, Enum.EasingStyle.Quart)
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
		Size = UDim2.fromOffset(0, 34),
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = host,
	})
	Components.New("UICorner", {CornerRadius = UDim.new(0, 10), Parent = pill})
	Components.New("UIStroke", {Color = color or Theme.Accent, Thickness = 1, Transparency = 0.3, Parent = pill})
	local lbl = Components.New("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Theme.Text,
		Parent = pill,
	})
	Components.Tween(pill, {Size = UDim2.fromOffset(math.clamp(#text * 7.5 + 32, 140, 300), 34)}, 0.22, Enum.EasingStyle.Back)
	task.delay(2.2, function()
		Components.Tween(pill, {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 34)}, 0.18).Completed:Connect(function()
			pill:Destroy()
		end)
		lbl.TextTransparency = 1
	end)
end

function Components.SectionHeader(parent, text, y)
	return Components.New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 22),
		Position = UDim2.fromOffset(16, y or 14),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent,
	})
end

return Components
