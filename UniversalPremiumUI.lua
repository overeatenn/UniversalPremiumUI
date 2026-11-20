-- UniversalPremiumUI v4.0
-- Novoline-inspired floating panel system + bottom nav + keybind manager
-- Visual / UI only · placeholders for exploit features

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")

local LP = Players.LocalPlayer
if not LP then return end
local PlayerGui = LP:WaitForChild("PlayerGui", 8)
if not PlayerGui then return end

pcall(function()
	local old = PlayerGui:FindFirstChild("UniversalPremium")
	if old then old:Destroy() end
end)

----------------------------------------------------------------
-- Config & Theme (Novoline dark)
----------------------------------------------------------------
local Theme = {
	Bg        = Color3.fromRGB(12, 12, 14),
	Card      = Color3.fromRGB(18, 18, 22),
	Card2     = Color3.fromRGB(24, 24, 29),
	Elevated  = Color3.fromRGB(30, 30, 36),
	Border    = Color3.fromRGB(42, 42, 50),
	Text      = Color3.fromRGB(235, 235, 240),
	Dim       = Color3.fromRGB(140, 140, 150),
	Muted     = Color3.fromRGB(95, 95, 105),
	Accent    = Color3.fromRGB(120, 100, 255), -- soft purple
	Accent2   = Color3.fromRGB(80, 160, 255),
	Success   = Color3.fromRGB(70, 200, 140),
	Danger    = Color3.fromRGB(230, 70, 90),
	Warn      = Color3.fromRGB(230, 170, 60),
}

local State = {
	Open = true,
	ActivePage = "Home",
	Dragging = nil,
	DragOffset = nil,
	KeybindListening = nil,
	Hue = 0,
	RGB = false,
	RGBConn = nil,
	Blur = nil,
}

-- Feature state + keybind data
-- Mode: "Toggle" | "Hold" | "Press"
local Features = {
	ESP = {
		Enabled = false, Box = true, Name = true, Dist = true, Team = true, MaxDist = 500,
		Key = Enum.KeyCode.E, Mode = "Toggle"
	},
	Aim = {
		Enabled = false, FOV = 110, Smooth = 0.22, Team = true, Visible = true,
		Key = Enum.KeyCode.Q, Mode = "Hold"
	},
	NPC = {
		Enabled = false, Lock = false, Range = 75,
		Key = Enum.KeyCode.R, Mode = "Toggle"
	},
	Hitbox = {
		Enabled = false, Show = true, Scale = 1,
		Key = Enum.KeyCode.H, Mode = "Toggle"
	},
	Fly = {
		Enabled = false, Speed = 50,
		Key = Enum.KeyCode.F, Mode = "Toggle"
	},
	Noclip = {
		Enabled = false,
		Key = Enum.KeyCode.V, Mode = "Toggle"
	},
	Speed = {
		Enabled = false, Value = 16,
		Key = Enum.KeyCode.X, Mode = "Toggle"
	},
	InfJump = {
		Enabled = false,
		Key = Enum.KeyCode.Space, Mode = "Hold"
	},
}

local KeyNames = {}
for _, k in pairs(Enum.KeyCode:GetEnumItems()) do
	KeyNames[k] = k.Name
end

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
local function New(class, props)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do i[k] = v end
	return i
end

local function Tw(obj, goals, t, style, dir)
	local info = TweenInfo.new(t or 0.22, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, goals)
	tw:Play()
	return tw
end

local function SoftShadow(parent, size, alpha)
	return New("ImageLabel", {
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

local function MakeCard(parent, size, pos)
	local f = New("Frame", {
		Size = size,
		Position = pos or UDim2.fromScale(0,0),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Parent = parent,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 12), Parent = f})
	New("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.55, Parent = f})
	SoftShadow(f, 14, 0.6)
	return f
end

local function MakeToggle(parent, size, pos, initial, onChange)
	local track = New("Frame", {
		Size = size or UDim2.fromOffset(36, 20),
		Position = pos or UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = initial and Theme.Accent or Theme.Border,
		BorderSizePixel = 0,
		Parent = parent,
	})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
	local knob = New("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = initial and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
		Parent = track,
	})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

	local function set(on)
		Tw(track, {BackgroundColor3 = on and Theme.Accent or Theme.Border}, 0.16)
		Tw(knob, {Position = on and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)}, 0.16, Enum.EasingStyle.Back)
	end

	local hit = New("TextButton", {
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

----------------------------------------------------------------
-- Root
----------------------------------------------------------------
local Gui = New("ScreenGui", {
	Name = "UniversalPremium",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true,
	Parent = PlayerGui,
})

-- Bottom navigation bar
local Nav = New("Frame", {
	Name = "Nav",
	Size = UDim2.fromOffset(420, 48),
	Position = UDim2.new(0.5, 0, 1, -28),
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundColor3 = Theme.Card,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Parent = Gui,
})
New("UICorner", {CornerRadius = UDim.new(0, 14), Parent = Nav})
New("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = Nav})
SoftShadow(Nav, 12, 0.55)

local NavLayout = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 4),
	Parent = Nav,
})
New("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = Nav})

local Pages = {}
local NavButtons = {}

local function MakeNavBtn(id, label, icon)
	local b = New("TextButton", {
		Name = id,
		Size = UDim2.fromOffset(62, 36),
		BackgroundColor3 = Theme.Elevated,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = Nav,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 10), Parent = b})
	local txt = New("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = label,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = Theme.Dim,
		Parent = b,
	})
	b.MouseEnter:Connect(function()
		if State.ActivePage ~= id then
			Tw(b, {BackgroundTransparency = 0.6}, 0.12)
			Tw(txt, {TextColor3 = Theme.Text}, 0.12)
		end
	end)
	b.MouseLeave:Connect(function()
		if State.ActivePage ~= id then
			Tw(b, {BackgroundTransparency = 1}, 0.12)
			Tw(txt, {TextColor3 = Theme.Dim}, 0.12)
		end
	end)
	b.MouseButton1Click:Connect(function() SwitchPage(id) end)
	NavButtons[id] = {Btn = b, Txt = txt}
	return b
end

MakeNavBtn("Home", "Home")
MakeNavBtn("Commands", "Cmds")
MakeNavBtn("Players", "Players")
MakeNavBtn("Scripts", "Scripts")
MakeNavBtn("Settings", "Settings")

----------------------------------------------------------------
-- Status pill (bottom center notifications)
----------------------------------------------------------------
local StatusHost = New("Frame", {
	Size = UDim2.fromOffset(280, 36),
	Position = UDim2.new(0.5, 0, 1, -90),
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundTransparency = 1,
	Parent = Gui,
})

local function Notify(text, color)
	local pill = New("Frame", {
		Size = UDim2.fromOffset(0, 32),
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Parent = StatusHost,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 10), Parent = pill})
	New("UIStroke", {Color = color or Theme.Accent, Thickness = 1, Transparency = 0.4, Parent = pill})
	local lbl = New("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Parent = pill,
	})
	Tw(pill, {Size = UDim2.fromOffset(math.clamp(#text * 7 + 28, 120, 260), 32)}, 0.25, Enum.EasingStyle.Back)
	task.delay(2.2, function()
		Tw(pill, {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 32)}, 0.2).Completed:Connect(function()
			pill:Destroy()
		end)
		lbl.TextTransparency = 1
	end)
end

----------------------------------------------------------------
-- Page containers (floating cards that appear/disappear)
----------------------------------------------------------------
local function MakePage(id)
	local page = New("Frame", {
		Name = id,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = Gui,
	})
	Pages[id] = page
	return page
end

function SwitchPage(id)
	if State.ActivePage == id then return end
	local old = State.ActivePage
	State.ActivePage = id

	if NavButtons[old] then
		Tw(NavButtons[old].Btn, {BackgroundTransparency = 1}, 0.15)
		Tw(NavButtons[old].Txt, {TextColor3 = Theme.Dim}, 0.15)
	end
	if NavButtons[id] then
		Tw(NavButtons[id].Btn, {BackgroundTransparency = 0.35}, 0.15)
		Tw(NavButtons[id].Txt, {TextColor3 = Theme.Text}, 0.15)
	end

	if Pages[old] then Pages[old].Visible = false end
	if Pages[id] then
		Pages[id].Visible = true
	end
end

----------------------------------------------------------------
-- HOME PAGE
----------------------------------------------------------------
local Home = MakePage("Home")

-- Left profile / FPS card
local profileCard = MakeCard(Home, UDim2.fromOffset(200, 160), UDim2.fromOffset(24, 80))
New("TextLabel", {
	Size = UDim2.new(1, -20, 0, 20),
	Position = UDim2.fromOffset(14, 12),
	BackgroundTransparency = 1,
	Text = "Universal Premium",
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = profileCard,
})
local fpsLbl = New("TextLabel", {
	Size = UDim2.new(1, -20, 0, 36),
	Position = UDim2.fromOffset(14, 40),
	BackgroundTransparency = 1,
	Text = "-- FPS",
	Font = Enum.Font.GothamBold,
	TextSize = 26,
	TextColor3 = Theme.Accent,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = profileCard,
})
New("TextLabel", {
	Size = UDim2.new(1, -20, 0, 16),
	Position = UDim2.fromOffset(14, 82),
	BackgroundTransparency = 1,
	Text = "v4.0  ·  Visual Shell",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.Muted,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = profileCard,
})

-- Quick actions card
local quickCard = MakeCard(Home, UDim2.fromOffset(220, 160), UDim2.fromOffset(240, 80))
New("TextLabel", {
	Size = UDim2.new(1, -16, 0, 18),
	Position = UDim2.fromOffset(12, 10),
	BackgroundTransparency = 1,
	Text = "Quick Actions",
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = Theme.Dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = quickCard,
})

local function QuickBtn(text, y, color, cb)
	local b = New("TextButton", {
		Size = UDim2.new(1, -24, 0, 32),
		Position = UDim2.fromOffset(12, y),
		BackgroundColor3 = color or Theme.Elevated,
		BackgroundTransparency = 0.25,
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Text,
		AutoButtonColor = false,
		Parent = quickCard,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = b})
	b.MouseEnter:Connect(function() Tw(b, {BackgroundTransparency = 0.05}, 0.12) end)
	b.MouseLeave:Connect(function() Tw(b, {BackgroundTransparency = 0.25}, 0.12) end)
	b.MouseButton1Click:Connect(cb)
end

QuickBtn("Open Commands", 38, Theme.Accent, function() SwitchPage("Commands") end)
QuickBtn("Open Settings", 78, Theme.Accent2, function() SwitchPage("Settings") end)
QuickBtn("Toggle UI (RightShift)", 118, Theme.Elevated, function() ToggleUI() end)

-- Server card
local serverCard = MakeCard(Home, UDim2.fromOffset(200, 120), UDim2.fromOffset(480, 80))
New("TextLabel", {
	Size = UDim2.new(1, -16, 0, 18),
	Position = UDim2.fromOffset(12, 10),
	BackgroundTransparency = 1,
	Text = "This Server",
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = Theme.Dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = serverCard,
})
local playerCount = New("TextLabel", {
	Size = UDim2.new(1, -16, 0, 28),
	Position = UDim2.fromOffset(12, 36),
	BackgroundTransparency = 1,
	Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers,
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = serverCard,
})
New("TextLabel", {
	Size = UDim2.new(1, -16, 0, 16),
	Position = UDim2.fromOffset(12, 72),
	BackgroundTransparency = 1,
	Text = "Players online",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.Muted,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = serverCard,
})

----------------------------------------------------------------
-- COMMANDS PAGE  (feature toggles + keybinds)
----------------------------------------------------------------
local Cmds = MakePage("Commands")

local cmdLeft = MakeCard(Cmds, UDim2.fromOffset(280, 380), UDim2.fromOffset(24, 60))
New("TextLabel", {
	Size = UDim2.new(1, -20, 0, 22),
	Position = UDim2.fromOffset(14, 12),
	BackgroundTransparency = 1,
	Text = "Quick Toggles",
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = cmdLeft,
})

local toggleList = New("ScrollingFrame", {
	Size = UDim2.new(1, -16, 1, -44),
	Position = UDim2.fromOffset(8, 40),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Theme.Border,
	CanvasSize = UDim2.new(0,0,0,0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent = cmdLeft,
})
New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = toggleList})

local function FeatureRow(name, featureKey, order)
	local row = New("Frame", {
		Size = UDim2.new(1, -4, 0, 40),
		BackgroundColor3 = Theme.Card2,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = toggleList,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = row})

	New("TextLabel", {
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

	local tg = MakeToggle(row, UDim2.fromOffset(36, 20), UDim2.new(1, -12, 0.5, 0), Features[featureKey].Enabled, function(on)
		Features[featureKey].Enabled = on
		Notify(name .. (on and " enabled" or " disabled"), on and Theme.Success or Theme.Dim)
	end)
end

FeatureRow("ESP", "ESP", 1)
FeatureRow("Aim (placeholder)", "Aim", 2)
FeatureRow("NPC Lock", "NPC", 3)
FeatureRow("Hitbox Visual", "Hitbox", 4)
FeatureRow("Fly (visual)", "Fly", 5)
FeatureRow("Noclip (visual)", "Noclip", 6)
FeatureRow("Speed", "Speed", 7)
FeatureRow("Infinite Jump", "InfJump", 8)

-- Right: Keybind manager
local keyCard = MakeCard(Cmds, UDim2.fromOffset(340, 380), UDim2.fromOffset(320, 60))
New("TextLabel", {
	Size = UDim2.new(1, -20, 0, 22),
	Position = UDim2.fromOffset(14, 12),
	BackgroundTransparency = 1,
	Text = "Keybinds",
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = keyCard,
})
New("TextLabel", {
	Size = UDim2.new(1, -20, 0, 16),
	Position = UDim2.fromOffset(14, 34),
	BackgroundTransparency = 1,
	Text = "Click a key to rebind · Cycle mode with the button",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.Muted,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = keyCard,
})

local keyList = New("ScrollingFrame", {
	Size = UDim2.new(1, -16, 1, -60),
	Position = UDim2.fromOffset(8, 56),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Theme.Border,
	CanvasSize = UDim2.new(0,0,0,0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent = keyCard,
})
New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = keyList})

local KeybindRows = {}

local function KeybindRow(display, featureKey, order)
	local feat = Features[featureKey]
	local row = New("Frame", {
		Size = UDim2.new(1, -4, 0, 42),
		BackgroundColor3 = Theme.Card2,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = keyList,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = row})

	New("TextLabel", {
		Size = UDim2.new(0.4, 0, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = display,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local keyBtn = New("TextButton", {
		Size = UDim2.fromOffset(70, 26),
		Position = UDim2.new(0.42, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Elevated,
		BackgroundTransparency = 0.2,
		Text = KeyNames[feat.Key] or "None",
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = Theme.Text,
		AutoButtonColor = false,
		Parent = row,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 6), Parent = keyBtn})

	local modeBtn = New("TextButton", {
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
	New("UICorner", {CornerRadius = UDim.new(0, 6), Parent = modeBtn})

	keyBtn.MouseButton1Click:Connect(function()
		State.KeybindListening = featureKey
		keyBtn.Text = "..."
		Tw(keyBtn, {BackgroundColor3 = Theme.Warn}, 0.12)
		Notify("Press a key for " .. display, Theme.Warn)
	end)

	modeBtn.MouseButton1Click:Connect(function()
		local order = {"Toggle", "Hold", "Press"}
		local idx = table.find(order, feat.Mode) or 1
		idx = idx % #order + 1
		feat.Mode = order[idx]
		modeBtn.Text = feat.Mode
		Notify(display .. " mode → " .. feat.Mode, Theme.Accent)
	end)

	KeybindRows[featureKey] = {KeyBtn = keyBtn, ModeBtn = modeBtn}
end

KeybindRow("ESP", "ESP", 1)
KeybindRow("Aim", "Aim", 2)
KeybindRow("NPC Lock", "NPC", 3)
KeybindRow("Hitbox", "Hitbox", 4)
KeybindRow("Fly", "Fly", 5)
KeybindRow("Noclip", "Noclip", 6)
KeybindRow("Speed", "Speed", 7)
KeybindRow("Inf Jump", "InfJump", 8)

----------------------------------------------------------------
-- PLAYERS PAGE (visual list only)
----------------------------------------------------------------
local PlayersPage = MakePage("Players")
local plrCard = MakeCard(PlayersPage, UDim2.fromOffset(320, 400), UDim2.fromOffset(40, 50))
New("TextLabel", {
	Size = UDim2.new(1, -20, 0, 22),
	Position = UDim2.fromOffset(14, 12),
	BackgroundTransparency = 1,
	Text = "Players",
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = plrCard,
})
local plrList = New("ScrollingFrame", {
	Size = UDim2.new(1, -16, 1, -44),
	Position = UDim2.fromOffset(8, 40),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Theme.Border,
	CanvasSize = UDim2.new(0,0,0,0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent = plrCard,
})
New("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = plrList})

local function RefreshPlayers()
	for _, c in pairs(plrList:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	for i, plr in ipairs(Players:GetPlayers()) do
		local row = New("Frame", {
			Size = UDim2.new(1, -4, 0, 36),
			BackgroundColor3 = Theme.Card2,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			LayoutOrder = i,
			Parent = plrList,
		})
		New("UICorner", {CornerRadius = UDim.new(0, 7), Parent = row})
		New("TextLabel", {
			Size = UDim2.new(1, -12, 1, 0),
			Position = UDim2.fromOffset(10, 0),
			BackgroundTransparency = 1,
			Text = plr.DisplayName .. "  (@" .. plr.Name .. ")",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = plr == LP and Theme.Accent or Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
	end
	playerCount.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
end
RefreshPlayers()
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

----------------------------------------------------------------
-- SCRIPTS PAGE (placeholder)
----------------------------------------------------------------
local ScriptsPage = MakePage("Scripts")
local scriptCard = MakeCard(ScriptsPage, UDim2.fromOffset(400, 200), UDim2.fromOffset(40, 80))
New("TextLabel", {
	Size = UDim2.new(1, -24, 0, 24),
	Position = UDim2.fromOffset(16, 20),
	BackgroundTransparency = 1,
	Text = "Scripts",
	Font = Enum.Font.GothamMedium,
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = scriptCard,
})
New("TextLabel", {
	Size = UDim2.new(1, -24, 0, 60),
	Position = UDim2.fromOffset(16, 56),
	BackgroundTransparency = 1,
	Text = "Script hub placeholder.\nThis shell is UI-only.\nLoad external scripts from your executor.",
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = Theme.Dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Parent = scriptCard,
})

----------------------------------------------------------------
-- SETTINGS PAGE
----------------------------------------------------------------
local SettingsPage = MakePage("Settings")
local setCard = MakeCard(SettingsPage, UDim2.fromOffset(360, 320), UDim2.fromOffset(40, 60))
New("TextLabel", {
	Size = UDim2.new(1, -20, 0, 22),
	Position = UDim2.fromOffset(14, 12),
	BackgroundTransparency = 1,
	Text = "Settings",
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = setCard,
})

local setList = New("Frame", {
	Size = UDim2.new(1, -20, 1, -50),
	Position = UDim2.fromOffset(10, 44),
	BackgroundTransparency = 1,
	Parent = setCard,
})
New("UIListLayout", {Padding = UDim.new(0, 6), Parent = setList})

local function SettingToggle(label, initial, cb)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Card2,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = setList,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = row})
	New("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = label,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	MakeToggle(row, UDim2.fromOffset(36, 20), UDim2.new(1, -12, 0.5, 0), initial, cb)
end

SettingToggle("Blur Background", true, function(on)
	if on then
		if not State.Blur then State.Blur = New("BlurEffect", {Size = 0, Parent = Lighting}) end
		Tw(State.Blur, {Size = 12}, 0.3)
	else
		if State.Blur then Tw(State.Blur, {Size = 0}, 0.25) end
	end
end)

SettingToggle("Rainbow RGB Accent", false, function(on)
	State.RGB = on
	if on then
		if State.RGBConn then State.RGBConn:Disconnect() end
		State.RGBConn = RunService.RenderStepped:Connect(function(dt)
			State.Hue = (State.Hue + dt * 0.25) % 1
			Theme.Accent = Color3.fromHSV(State.Hue, 0.55, 1)
		end)
	else
		if State.RGBConn then State.RGBConn:Disconnect() State.RGBConn = nil end
		Theme.Accent = Color3.fromRGB(120, 100, 255)
	end
end)

----------------------------------------------------------------
-- Input / Keybind system
----------------------------------------------------------------
local held = {}

UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end

	-- Keybind listening
	if State.KeybindListening and inp.UserInputType == Enum.UserInputType.Keyboard then
		local featKey = State.KeybindListening
		Features[featKey].Key = inp.KeyCode
		if KeybindRows[featKey] then
			KeybindRows[featKey].KeyBtn.Text = KeyNames[inp.KeyCode] or inp.KeyCode.Name
			Tw(KeybindRows[featKey].KeyBtn, {BackgroundColor3 = Theme.Elevated}, 0.12)
		end
		State.KeybindListening = nil
		Notify("Bound to " .. (KeyNames[inp.KeyCode] or inp.KeyCode.Name), Theme.Success)
		return
	end

	-- UI toggle
	if inp.KeyCode == Enum.KeyCode.RightShift then
		ToggleUI()
		return
	end

	-- Feature keybinds
	for name, feat in pairs(Features) do
		if feat.Key == inp.KeyCode then
			if feat.Mode == "Toggle" then
				feat.Enabled = not feat.Enabled
				Notify(name .. (feat.Enabled and " on" or " off"), feat.Enabled and Theme.Success or Theme.Dim)
			elseif feat.Mode == "Hold" then
				feat.Enabled = true
				held[name] = true
			elseif feat.Mode == "Press" then
				feat.Enabled = true
				Notify(name .. " pressed", Theme.Accent)
				task.delay(0.15, function() feat.Enabled = false end)
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(inp)
	for name, feat in pairs(Features) do
		if feat.Key == inp.KeyCode and feat.Mode == "Hold" and held[name] then
			feat.Enabled = false
			held[name] = nil
		end
	end
end)

----------------------------------------------------------------
-- UI toggle + FPS counter
----------------------------------------------------------------
function ToggleUI()
	State.Open = not State.Open
	for _, page in pairs(Pages) do
		page.Visible = State.Open and (page.Name == State.ActivePage)
	end
	Nav.Visible = State.Open
	if State.Open then
		Notify("UI opened", Theme.Accent)
	else
		Notify("UI closed · RightShift", Theme.Dim)
	end
end

-- FPS
task.spawn(function()
	local frames = 0
	local last = tick()
	RunService.RenderStepped:Connect(function()
		frames += 1
		if tick() - last >= 1 then
			fpsLbl.Text = frames .. " FPS"
			frames = 0
			last = tick()
		end
	end)
end)

-- Boot
SwitchPage("Home")
if not State.Blur then
	State.Blur = New("BlurEffect", {Size = 0, Parent = Lighting})
	Tw(State.Blur, {Size = 10}, 0.4)
end
Notify("Universal Premium v4.0 loaded", Theme.Accent)
print("[UniversalPremium v4.0] Novoline-style shell — RightShift to toggle")
