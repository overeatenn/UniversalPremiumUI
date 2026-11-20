-- Commands + Keybinds page
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

	-- Left toggles
	local left = Components.Card(page, UDim2.fromOffset(290, 400), UDim2.fromOffset(24, 50))
	Components.New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 22),
		Position = UDim2.fromOffset(14, 12),
		BackgroundTransparency = 1,
		Text = "Quick Toggles",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = left,
	})

	local list = Components.New("ScrollingFrame", {
		Size = UDim2.new(1, -16, 1, -44),
		Position = UDim2.fromOffset(8, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Border,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = left,
	})
	Components.New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})

	local function featureRow(name, key, order)
		local row = Components.New("Frame", {
			Size = UDim2.new(1, -4, 0, 40),
			BackgroundColor3 = Theme.Card2,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			LayoutOrder = order,
			Parent = list,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = row})
		Components.New("TextLabel", {
			Size = UDim2.new(0.55, 0, 1, 0),
			Position = UDim2.fromOffset(10, 0),
			BackgroundTransparency = 1,
			Text = name,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		Components.Toggle(row, UDim2.fromOffset(36, 20), UDim2.new(1, -12, 0.5, 0), State.Features[key].Enabled, function(on)
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

	-- Right keybinds
	local right = Components.Card(page, UDim2.fromOffset(350, 400), UDim2.fromOffset(330, 50))
	Components.New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 22),
		Position = UDim2.fromOffset(14, 12),
		BackgroundTransparency = 1,
		Text = "Keybinds",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = right,
	})
	Components.New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 16),
		Position = UDim2.fromOffset(14, 34),
		BackgroundTransparency = 1,
		Text = "Click key to rebind · Mode cycles Toggle / Hold / Press",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = right,
	})

	local klist = Components.New("ScrollingFrame", {
		Size = UDim2.new(1, -16, 1, -60),
		Position = UDim2.fromOffset(8, 56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Border,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})
	Components.New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = klist})

	local rows = {}
	local function keyRow(display, key, order)
		local feat = State.Features[key]
		local row = Components.New("Frame", {
			Size = UDim2.new(1, -4, 0, 42),
			BackgroundColor3 = Theme.Card2,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			LayoutOrder = order,
			Parent = klist,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = row})
		Components.New("TextLabel", {
			Size = UDim2.new(0.38, 0, 1, 0),
			Position = UDim2.fromOffset(10, 0),
			BackgroundTransparency = 1,
			Text = display,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})

		local keyBtn = Components.New("TextButton", {
			Size = UDim2.fromOffset(72, 26),
			Position = UDim2.new(0.4, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.Elevated,
			BackgroundTransparency = 0.2,
			Text = Keybinds.Name(feat.Key),
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = Theme.Text,
			AutoButtonColor = false,
			Parent = row,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 6), Parent = keyBtn})

		local modeBtn = Components.New("TextButton", {
			Size = UDim2.fromOffset(64, 26),
			Position = UDim2.new(1, -76, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.35,
			Text = feat.Mode,
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = Theme.Text,
			AutoButtonColor = false,
			Parent = row,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 6), Parent = modeBtn})

		Keybinds.BindListener(key, keyBtn, notifyFn)
		Keybinds.ModeCycle(key, modeBtn, notifyFn)

		rows[key] = {KeyBtn = keyBtn, ModeBtn = modeBtn}
	end

	keyRow("ESP", "ESP", 1)
	keyRow("Aim", "Aim", 2)
	keyRow("NPC Lock", "NPC", 3)
	keyRow("Hitbox", "Hitbox", 4)
	keyRow("Fly", "Fly", 5)
	keyRow("Noclip", "Noclip", 6)
	keyRow("Speed", "Speed", 7)
	keyRow("Inf Jump", "InfJump", 8)

	return page, rows
end

return Commands
