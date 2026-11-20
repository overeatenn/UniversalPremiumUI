-- Settings v4.2
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Settings = {}
local Theme, State, Components

function Settings.Init(theme, state, components)
	Theme = theme
	State = state
	Components = components
end

function Settings.Build(parent)
	local page = Components.New("Frame", {
		Name = "Settings",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local card = Components.Card(page, UDim2.fromOffset(400, 280), UDim2.fromOffset(36, 64))
	Components.SectionHeader(card, "Settings", 16)

	local list = Components.New("Frame", {
		Size = UDim2.new(1, -24, 1, -56),
		Position = UDim2.fromOffset(12, 52),
		BackgroundTransparency = 1,
		Parent = card,
	})
	Components.New("UIListLayout", {Padding = UDim.new(0, 8), Parent = list})

	local function setting(label, initial, cb)
		local row = Components.New("Frame", {
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = Theme.Card2,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Parent = list,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 10), Parent = row})
		Components.New("TextLabel", {
			Size = UDim2.new(1, -70, 1, 0),
			Position = UDim2.fromOffset(16, 0),
			BackgroundTransparency = 1,
			Text = label,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		Components.Toggle(row, UDim2.fromOffset(42, 24), UDim2.new(1, -16, 0.5, 0), initial, cb)
	end

	setting("Blur Background", true, function(on)
		if on then
			if not State.Blur then State.Blur = Instance.new("BlurEffect", Lighting) State.Blur.Size = 0 end
			Components.Tween(State.Blur, {Size = 12}, 0.3)
		else
			if State.Blur then Components.Tween(State.Blur, {Size = 0}, 0.25) end
		end
	end)

	setting("Rainbow RGB Accent", false, function(on)
		State.RGB = on
		if on then
			if State.RGBConn then State.RGBConn:Disconnect() end
			State.RGBConn = RunService.RenderStepped:Connect(function(dt)
				State.Hue = (State.Hue + dt * 0.25) % 1
				Theme.Accent = Color3.fromHSV(State.Hue, 0.55, 1)
			end)
		else
			if State.RGBConn then State.RGBConn:Disconnect() State.RGBConn = nil end
			Theme.Accent = Color3.fromRGB(130, 110, 255)
		end
	end)

	return page
end

return Settings
