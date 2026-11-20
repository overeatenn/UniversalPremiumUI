-- Commands + Keybinds v4.2
local Commands = {}
local Theme, State, Components, Keybinds

function Commands.Init(theme, state, components, keybinds)
	Theme = theme
	State = state
	Components = components
	Keybinds = keybinds
end

function Commands.Build(parent, notifyFn)
	local page = Components.New("Frame", {
		Name = "Commands",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	-- Left: toggles
	local left = Components.Card(page, UDim2.fromOffset(320, 440), UDim2.fromOffset(28, 48))
	Components.SectionHeader(left, "Quick Toggles", 16)

	local list = Components.New("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -52),
		Position = UDim2.fromOffset(10, 48),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Border,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = left,
	})
	Components.New("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})
	Components.New("UIPadding", {PaddingTop = UDim.new(0, 2), Parent = list})

	local function featureRow(name, key, order)
		local row = Components.New("Frame", {
			Size = UDim2.new(1, -6, 0, 44),
			BackgroundColor3 = Theme.Card2,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			LayoutOrder = order,
			Parent = list,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 10), Parent = row})
		Components.New("TextLabel", {
			Size = UDim2.new(0.58, 0, 1, 0),
			Position = UDim2.fromOffset(14, 0),
			BackgroundTransparency = 1,
			Text = name,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		Components.Toggle(row, UDim2.fromOffset(42, 24), UDim2.new(1, -14, 0.5, 0), State.Features[key].Enabled, function(on)
			State.Features[key].Enabled = on
			if notifyFn then notifyFn(name .. (on and " enabled" or " disabled"), on and Theme.Success or Theme.Dim) end
		end)
	end

	featureRow("ESP", "ESP", 1)
	featureRow("Aim (placeholder)", "Aim", 2)
	featureRow("NPC Lock", "NPC", 3)
	featureRow("Hitbox Visual", "Hitbox", 4)
	featureRow("Fly (visual)", "Fly", 5)
	featureRow("Noclip (visual)", "Noclip", 6)
	featureRow("Speed", "Speed", 7)
	featureRow("Infinite Jump", "InfJump", 8)

	-- Right: keybinds
	local right = Components.Card(page, UDim2.fromOffset(380, 440), UDim2.fromOffset(368, 48))
	Components.SectionHeader(right, "Keybinds", 16)
	Components.New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 16),
		Position = UDim2.fromOffset(16, 40),
		BackgroundTransparency = 1,
		Text = "Click key to rebind  ·  Mode cycles Toggle / Hold / Press",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = right,
	})

	local klist = Components.New("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -68),
		Position = UDim2.fromOffset(10, 64),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Border,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})
	Components.New("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = klist})

	local function keyRow(display, key, order)
		local feat = State.Features[key]
		local row = Components.New("Frame", {
			Size = UDim2.new(1, -6, 0, 46),
			BackgroundColor3 = Theme.Card2,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			LayoutOrder = order,
			Parent = klist,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 10), Parent = row})
		Components.New("TextLabel", {
			Size = UDim2.new(0.36, 0, 1, 0),
			Position = UDim2.fromOffset(14, 0),
			BackgroundTransparency = 1,
			Text = display,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})

		local keyBtn = Components.New("TextButton", {
			Size = UDim2.fromOffset(78, 28),
			Position = UDim2.new(0.4, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.Elevated,
			BackgroundTransparency = 0.15,
			Text = Keybinds.Name(feat.Key),
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = Theme.Text,
			AutoButtonColor = false,
			Parent = row,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = keyBtn})

		local modeBtn = Components.New("TextButton", {
			Size = UDim2.fromOffset(70, 28),
			Position = UDim2.new(1, -84, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.3,
			Text = feat.Mode,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = Theme.Text,
			AutoButtonColor = false,
			Parent = row,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = modeBtn})

		Keybinds.BindListener(key, keyBtn, notifyFn)
		Keybinds.ModeCycle(key, modeBtn, notifyFn)
	end

	keyRow("ESP", "ESP", 1)
	keyRow("Aim", "Aim", 2)
	keyRow("NPC Lock", "NPC", 3)
	keyRow("Hitbox", "Hitbox", 4)
	keyRow("Fly", "Fly", 5)
	keyRow("Noclip", "Noclip", 6)
	keyRow("Speed", "Speed", 7)
	keyRow("Inf Jump", "InfJump", 8)

	return page
end

return Commands
