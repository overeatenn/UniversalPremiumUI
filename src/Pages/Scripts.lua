-- Scripts v4.2
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

	local card = Components.Card(page, UDim2.fromOffset(460, 240), UDim2.fromOffset(36, 80))
	Components.SectionHeader(card, "Scripts", 18)
	Components.New("TextLabel", {
		Size = UDim2.new(1, -32, 0, 80),
		Position = UDim2.fromOffset(16, 56),
		BackgroundTransparency = 1,
		Text = "Script hub is a visual placeholder.\nThis shell is UI-only.\nLoad external scripts from your executor.",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = card,
	})

	return page
end

return Scripts
