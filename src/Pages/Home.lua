-- Home v4.2
local Players = game:GetService("Players")
local Home = {}
local Theme, State, Components

function Home.Init(theme, state, components)
	Theme = theme
	State = state
	Components = components
end

function Home.Build(parent, switchPage, toggleUI)
	local page = Components.New("Frame", {
		Name = "Home",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	-- Profile / FPS — larger
	local profile = Components.Card(page, UDim2.fromOffset(240, 190), UDim2.fromOffset(36, 64))
	Components.SectionHeader(profile, "Universal Premium", 16)
	local fps = Components.New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 42),
		Position = UDim2.fromOffset(16, 48),
		BackgroundTransparency = 1,
		Text = "-- FPS",
		Font = Enum.Font.GothamBold,
		TextSize = 30,
		TextColor3 = Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profile,
	})
	Components.New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 18),
		Position = UDim2.fromOffset(16, 98),
		BackgroundTransparency = 1,
		Text = "v4.2  ·  Multi-module",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profile,
	})
	Components.New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 16),
		Position = UDim2.fromOffset(16, 130),
		BackgroundTransparency = 1,
		Text = "RightShift to hide",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profile,
	})

	-- Quick actions
	local quick = Components.Card(page, UDim2.fromOffset(260, 190), UDim2.fromOffset(296, 64))
	Components.SectionHeader(quick, "Quick Actions", 16)

	local function qbtn(text, y, col, cb)
		local b = Components.New("TextButton", {
			Size = UDim2.new(1, -28, 0, 38),
			Position = UDim2.fromOffset(14, y),
			BackgroundColor3 = col or Theme.Elevated,
			BackgroundTransparency = 0.2,
			Text = text,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = Theme.Text,
			AutoButtonColor = false,
			Parent = quick,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 10), Parent = b})
		b.MouseEnter:Connect(function() Components.Tween(b, {BackgroundTransparency = 0.05}, 0.12) end)
		b.MouseLeave:Connect(function() Components.Tween(b, {BackgroundTransparency = 0.2}, 0.12) end)
		b.MouseButton1Click:Connect(cb)
	end

	qbtn("Open Commands", 48, Theme.Accent, function() switchPage("Commands") end)
	qbtn("Open Settings", 96, Theme.Accent2, function() switchPage("Settings") end)
	qbtn("Toggle UI", 144, Theme.Elevated, function() toggleUI() end)

	-- Server card
	local server = Components.Card(page, UDim2.fromOffset(220, 140), UDim2.fromOffset(576, 64))
	Components.SectionHeader(server, "This Server", 16)
	Components.New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 34),
		Position = UDim2.fromOffset(16, 50),
		BackgroundTransparency = 1,
		Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers,
		Font = Enum.Font.GothamBold,
		TextSize = 26,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = server,
	})
	Components.New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 16),
		Position = UDim2.fromOffset(16, 96),
		BackgroundTransparency = 1,
		Text = "Players online",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = server,
	})

	return page, fps
end

return Home
