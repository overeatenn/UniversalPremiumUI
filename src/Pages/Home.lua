-- Home page
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

	-- Profile / FPS
	local profile = Components.Card(page, UDim2.fromOffset(210, 170), UDim2.fromOffset(28, 70))
	Components.New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.fromOffset(14, 12),
		BackgroundTransparency = 1,
		Text = "Universal Premium",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profile,
	})
	local fps = Components.New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 36),
		Position = UDim2.fromOffset(14, 42),
		BackgroundTransparency = 1,
		Text = "-- FPS",
		Font = Enum.Font.GothamBold,
		TextSize = 26,
		TextColor3 = Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profile,
	})
	Components.New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 16),
		Position = UDim2.fromOffset(14, 86),
		BackgroundTransparency = 1,
		Text = "v4.1  ·  Multi-module",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profile,
	})

	-- Quick actions
	local quick = Components.Card(page, UDim2.fromOffset(230, 170), UDim2.fromOffset(256, 70))
	Components.New("TextLabel", {
		Size = UDim2.new(1, -16, 0, 18),
		Position = UDim2.fromOffset(12, 10),
		BackgroundTransparency = 1,
		Text = "Quick Actions",
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = quick,
	})

	local function qbtn(text, y, col, cb)
		local b = Components.New("TextButton", {
			Size = UDim2.new(1, -24, 0, 34),
			Position = UDim2.fromOffset(12, y),
			BackgroundColor3 = col or Theme.Elevated,
			BackgroundTransparency = 0.25,
			Text = text,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = Theme.Text,
			AutoButtonColor = false,
			Parent = quick,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = b})
		b.MouseEnter:Connect(function() Components.Tween(b, {BackgroundTransparency = 0.05}, 0.12) end)
		b.MouseLeave:Connect(function() Components.Tween(b, {BackgroundTransparency = 0.25}, 0.12) end)
		b.MouseButton1Click:Connect(cb)
	end

	qbtn("Open Commands", 40, Theme.Accent, function() switchPage("Commands") end)
	qbtn("Open Settings", 82, Theme.Accent2, function() switchPage("Settings") end)
	qbtn("Toggle UI (RightShift)", 124, Theme.Elevated, function() toggleUI() end)

	-- Server
	local server = Components.Card(page, UDim2.fromOffset(210, 120), UDim2.fromOffset(504, 70))
	Components.New("TextLabel", {
		Size = UDim2.new(1, -16, 0, 18),
		Position = UDim2.fromOffset(12, 10),
		BackgroundTransparency = 1,
		Text = "This Server",
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = server,
	})
	local count = Components.New("TextLabel", {
		Size = UDim2.new(1, -16, 0, 28),
		Position = UDim2.fromOffset(12, 38),
		BackgroundTransparency = 1,
		Text = #game:GetService("Players"):GetPlayers() .. " / " .. game:GetService("Players").MaxPlayers,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = server,
	})

	return page, fps, count
end

return Home
