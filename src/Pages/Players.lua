-- Players v4.2
local Players = game:GetService("Players")
local PlayersPage = {}
local Theme, State, Components

function PlayersPage.Init(theme, state, components)
	Theme = theme
	State = state
	Components = components
end

function PlayersPage.Build(parent)
	local page = Components.New("Frame", {
		Name = "Players",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local card = Components.Card(page, UDim2.fromOffset(380, 460), UDim2.fromOffset(36, 48))
	Components.SectionHeader(card, "Players", 16)

	local list = Components.New("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -52),
		Position = UDim2.fromOffset(10, 48),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Border,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = card,
	})
	Components.New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})

	local function refresh()
		for _, c in pairs(list:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end
		for i, plr in ipairs(Players:GetPlayers()) do
			local row = Components.New("Frame", {
				Size = UDim2.new(1, -6, 0, 40),
				BackgroundColor3 = Theme.Card2,
				BackgroundTransparency = 0.3,
				BorderSizePixel = 0,
				LayoutOrder = i,
				Parent = list,
			})
			Components.New("UICorner", {CornerRadius = UDim.new(0, 9), Parent = row})
			Components.New("TextLabel", {
				Size = UDim2.new(1, -16, 1, 0),
				Position = UDim2.fromOffset(14, 0),
				BackgroundTransparency = 1,
				Text = plr.DisplayName .. "  (@" .. plr.Name .. ")",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = plr == Players.LocalPlayer and Theme.Accent or Theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
			})
		end
	end

	refresh()
	Players.PlayerAdded:Connect(refresh)
	Players.PlayerRemoving:Connect(refresh)

	return page
end

return PlayersPage
