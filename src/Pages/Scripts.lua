-- Scripts placeholder page
local Scripts = {}
local Theme, State, Components

function Scripts.Init(theme, state, components)
	Theme = theme
	State = state
	Components = components
end

function Scripts.Build(parent)
	local page = Components.New("Frame", {
		Name = "Scripts",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local card = Components.Card(page, UDim2.fromOffset(420, 210), UDim2.fromOffset(40, 80))
	Components.New("TextLabel", {
		Size = UDim2.new(1, -24, 0, 24),
		Position = UDim2.fromOffset(16, 20),
		BackgroundTransparency = 1,
		Text = "Scripts",
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	Components.New("TextLabel", {
		Size = UDim2.new(1, -24, 0, 70),
		Position = UDim2.fromOffset(16, 56),
		BackgroundTransparency = 1,
		Text = "Script hub is a visual placeholder.\nThis shell is UI-only.\nLoad external scripts from your executor.",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = card,
	})

	return page
end

return Scripts
