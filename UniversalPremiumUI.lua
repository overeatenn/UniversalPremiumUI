-- UniversalPremiumUI v2.5 | pure UI only | no character / HumanoidDescription code
-- RightShift toggles | destroy previous instance to prevent stack errors from other scripts

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")

local LP = Players.LocalPlayer
if not LP then return end
local PlayerGui = LP:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

-- kill any previous copy
pcall(function()
	local old = PlayerGui:FindFirstChild("UniversalPremium")
	if old then old:Destroy() end
end)

local CFG = {
	OpenKey   = Enum.KeyCode.RightShift,
	Theme     = "Dark",
	RGBSpeed  = 0.28,
	AnimSpeed = 0.22,
}

local C = {
	Bg      = Color3.fromRGB(10, 10, 12),
	Panel   = Color3.fromRGB(18, 18, 22),
	Panel2  = Color3.fromRGB(24, 24, 30),
	Border  = Color3.fromRGB(42, 42, 50),
	Text    = Color3.fromRGB(235, 235, 240),
	Dim     = Color3.fromRGB(140, 140, 150),
	Accent  = Color3.fromRGB(115, 135, 255),
	Danger  = Color3.fromRGB(210, 75, 90),
}

local State = {
	Open = false,
	Tab = "ESP",
	Hue = 0,
	RGBConn = nil,
	Dragging = false,
	DragStart = nil,
	StartPos = nil,
	Blur = nil,
}

local Settings = {
	ESP         = {Enabled=false, Box=true, Name=true, Dist=true, Team=true, Max=500},
	Aim         = {Enabled=false, FOV=110, Smooth=0.22, Team=true, Visible=true},
	NPC         = {Enabled=false, Lock=false, Range=75},
	Hitbox      = {Enabled=false, Show=true, Scale=1},
	Movement    = {Speed=16, Jump=50, Fly=false, Noclip=false},
	Crosshair   = {Enabled=true, Size=11, Thick=1, Gap=4},
	Performance = {Low=false, Rate=60},
	UI          = {Blur=true},
}

local function New(class, props)
	local i = Instance.new(class)
	for k,v in pairs(props or {}) do i[k] = v end
	return i
end

local function Tw(obj, goals, t)
	local tw = TweenService:Create(obj, TweenInfo.new(t or CFG.AnimSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goals)
	tw:Play()
	return tw
end

----------------------------------------------------------------
-- GUI root
----------------------------------------------------------------
local Gui = New("ScreenGui", {
	Name = "UniversalPremium",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true,
	Parent = PlayerGui,
})

local Main = New("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(720, 470),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.Panel,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Visible = false,
	Parent = Gui,
})
New("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Main})
New("UIStroke", {Color = C.Border, Thickness = 1, Transparency = 0.25, Parent = Main})

-- soft shadow
local sh = New("ImageLabel", {
	Name = "Shadow",
	BackgroundTransparency = 1,
	Image = "rbxassetid://6014261993",
	ImageColor3 = Color3.new(0,0,0),
	ImageTransparency = 0.5,
	ScaleType = Enum.ScaleType.Slice,
	SliceCenter = Rect.new(49,49,450,450),
	Size = UDim2.new(1, 32, 1, 32),
	Position = UDim2.fromOffset(-16, -16),
	ZIndex = 0,
	Parent = Main,
})

----------------------------------------------------------------
-- Title
----------------------------------------------------------------
local TitleBar = New("Frame", {
	Size = UDim2.new(1, 0, 0, 38),
	BackgroundColor3 = C.Bg,
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	Parent = Main,
})
New("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TitleBar})
New("Frame", {
	Size = UDim2.new(1, 0, 0, 10),
	Position = UDim2.new(0, 0, 1, -10),
	BackgroundColor3 = C.Bg,
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	Parent = TitleBar,
})

New("TextLabel", {
	Size = UDim2.new(0, 280, 1, 0),
	Position = UDim2.fromOffset(14, 0),
	BackgroundTransparency = 1,
	Text = "UNIVERSAL  ·  PREMIUM",
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextColor3 = C.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = TitleBar,
})
New("TextLabel", {
	Size = UDim2.new(0, 50, 1, 0),
	Position = UDim2.fromOffset(200, 0),
	BackgroundTransparency = 1,
	Text = "v2.5",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = C.Dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = TitleBar,
})

local function Dot(x, color, cb)
	local b = New("TextButton", {
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, x, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.55,
		Text = "",
		AutoButtonColor = false,
		Parent = TitleBar,
	})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = b})
	b.MouseEnter:Connect(function() Tw(b, {BackgroundTransparency = 0.2}, 0.1) end)
	b.MouseLeave:Connect(function() Tw(b, {BackgroundTransparency = 0.55}, 0.1) end)
	b.MouseButton1Click:Connect(cb)
end

Dot(-18, C.Danger, function() Toggle(false) end)
Dot(-46, C.Dim, function() Tw(Main, {Size = UDim2.fromOffset(720, 38)}, 0.25) end)

-- drag
TitleBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		State.Dragging = true
		State.DragStart = i.Position
		State.StartPos = Main.Position
	end
end)
TitleBar.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then State.Dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
	if State.Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - State.DragStart
		Main.Position = UDim2.new(State.StartPos.X.Scale, State.StartPos.X.Offset + d.X, State.StartPos.Y.Scale, State.StartPos.Y.Offset + d.Y)
	end
end)

----------------------------------------------------------------
-- Sidebar
----------------------------------------------------------------
local Side = New("Frame", {
	Size = UDim2.new(0, 148, 1, -38),
	Position = UDim2.fromOffset(0, 38),
	BackgroundColor3 = C.Bg,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	Parent = Main,
})

local SideList = New("ScrollingFrame", {
	Size = UDim2.new(1, -4, 1, -8),
	Position = UDim2.fromOffset(2, 4),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = C.Border,
	CanvasSize = UDim2.new(0,0,0,0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent = Side,
})
New("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SideList})

local Content = New("Frame", {
	Size = UDim2.new(1, -156, 1, -46),
	Position = UDim2.fromOffset(152, 42),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Parent = Main,
})

local Tabs, TabBtns = {}, {}

local function MakeTab(id, label, order)
	local btn = New("TextButton", {
		Name = id,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = C.Panel2,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = order,
		Parent = SideList,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})

	local ind = New("Frame", {
		Size = UDim2.fromOffset(3, 14),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = C.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = btn,
	})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ind})

	local txt = New("TextLabel", {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = label,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = C.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = btn,
	})

	btn.MouseEnter:Connect(function()
		if State.Tab ~= id then
			Tw(btn, {BackgroundTransparency = 0.6}, 0.1)
			Tw(txt, {TextColor3 = C.Text}, 0.1)
		end
	end)
	btn.MouseLeave:Connect(function()
		if State.Tab ~= id then
			Tw(btn, {BackgroundTransparency = 1}, 0.1)
			Tw(txt, {TextColor3 = C.Dim}, 0.1)
		end
	end)
	btn.MouseButton1Click:Connect(function() SwitchTab(id) end)

	TabBtns[id] = {Btn=btn, Ind=ind, Txt=txt}
end

MakeTab("ESP", "ESP", 1)
MakeTab("Aim", "Aim", 2)
MakeTab("NPC", "NPC Lock", 3)
MakeTab("Hitbox", "Hitbox", 4)
MakeTab("Movement", "Movement", 5)
MakeTab("Crosshair", "Crosshair", 6)
MakeTab("Performance", "Perf", 7)
MakeTab("UI", "UI", 8)
MakeTab("Config", "Config", 9)

----------------------------------------------------------------
-- Panel helpers
----------------------------------------------------------------
local function MakePanel(name)
	local f = New("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.Border,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = Content,
	})
	New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f})
	New("UIPadding", {PaddingTop=UDim.new(0,2), PaddingLeft=UDim.new(0,2), PaddingRight=UDim.new(0,6), PaddingBottom=UDim.new(0,8), Parent = f})
	Tabs[name] = f
	return f
end

local function Section(parent, title, order)
	local h = New("Frame", {Size = UDim2.new(1,0,0,22), BackgroundTransparency=1, LayoutOrder=order, Parent=parent})
	New("TextLabel", {
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = C.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = h,
	})
end

local function ToggleRow(parent, label, key, subkey, order)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = C.Panel2,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = parent,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 7), Parent = row})

	New("TextLabel", {
		Size = UDim2.new(1, -64, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = label,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local track = New("Frame", {
		Size = UDim2.fromOffset(36, 18),
		Position = UDim2.new(1, -46, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = C.Border,
		BorderSizePixel = 0,
		Parent = row,
	})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})

	local knob = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = C.Text,
		BorderSizePixel = 0,
		Parent = track,
	})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

	local function refresh()
		local on = Settings[key][subkey]
		Tw(track, {BackgroundColor3 = on and C.Accent or C.Border}, 0.15)
		Tw(knob, {Position = on and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)}, 0.15)
	end
	refresh()

	local hit = New("TextButton", {Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", Parent=row})
	hit.MouseButton1Click:Connect(function()
		Settings[key][subkey] = not Settings[key][subkey]
		refresh()
	end)
end

local function SliderRow(parent, label, key, subkey, min, max, order)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = C.Panel2,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = parent,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 7), Parent = row})

	local val = New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 18),
		Position = UDim2.fromOffset(10, 4),
		BackgroundTransparency = 1,
		Text = label .. ": " .. tostring(Settings[key][subkey]),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local bar = New("Frame", {
		Size = UDim2.new(1, -20, 0, 5),
		Position = UDim2.new(0, 10, 1, -14),
		BackgroundColor3 = C.Border,
		BorderSizePixel = 0,
		Parent = row,
	})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bar})

	local fill = New("Frame", {
		Size = UDim2.new((Settings[key][subkey]-min)/(max-min), 0, 1, 0),
		BackgroundColor3 = C.Accent,
		BorderSizePixel = 0,
		Parent = bar,
	})
	New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

	local hit = New("TextButton", {Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", Parent=bar})
	hit.MouseButton1Click:Connect(function()
		local mx = UserInputService:GetMouseLocation().X
		local abs = bar.AbsolutePosition.X
		local sz = bar.AbsoluteSize.X
		local pct = math.clamp((mx - abs) / sz, 0, 1)
		local v = math.floor(min + pct * (max - min) + 0.5)
		Settings[key][subkey] = v
		fill.Size = UDim2.new(pct, 0, 1, 0)
		val.Text = label .. ": " .. v
	end)
end

----------------------------------------------------------------
-- Build panels
----------------------------------------------------------------
local p = MakePanel("ESP")
Section(p, "ESP VISUALIZATION", 1)
ToggleRow(p, "Master Toggle", "ESP", "Enabled", 2)
ToggleRow(p, "Bounding Box", "ESP", "Box", 3)
ToggleRow(p, "Name Tags", "ESP", "Name", 4)
ToggleRow(p, "Distance", "ESP", "Dist", 5)
ToggleRow(p, "Team Check", "ESP", "Team", 6)
SliderRow(p, "Max Distance", "ESP", "Max", 50, 2000, 7)

p = MakePanel("Aim")
Section(p, "AIM TRAINER (PLACEHOLDER)", 1)
ToggleRow(p, "Enabled", "Aim", "Enabled", 2)
SliderRow(p, "FOV", "Aim", "FOV", 30, 300, 3)
SliderRow(p, "Smoothness", "Aim", "Smooth", 0, 1, 4)
ToggleRow(p, "Team Check", "Aim", "Team", 5)
ToggleRow(p, "Visible Check", "Aim", "Visible", 6)

p = MakePanel("NPC")
Section(p, "NPC LOCK (VISUAL ONLY)", 1)
ToggleRow(p, "Enabled", "NPC", "Enabled", 2)
ToggleRow(p, "Lock", "NPC", "Lock", 3)
SliderRow(p, "Range", "NPC", "Range", 10, 200, 4)

p = MakePanel("Hitbox")
Section(p, "HITBOX VISUAL", 1)
ToggleRow(p, "Enabled", "Hitbox", "Enabled", 2)
ToggleRow(p, "Show Boxes", "Hitbox", "Show", 3)
SliderRow(p, "Scale", "Hitbox", "Scale", 0.5, 3, 4)

p = MakePanel("Movement")
Section(p, "MOVEMENT", 1)
SliderRow(p, "WalkSpeed", "Movement", "Speed", 8, 100, 2)
SliderRow(p, "JumpPower", "Movement", "Jump", 20, 150, 3)
ToggleRow(p, "Fly (visual)", "Movement", "Fly", 4)
ToggleRow(p, "Noclip (visual)", "Movement", "Noclip", 5)

p = MakePanel("Crosshair")
Section(p, "CROSSHAIR", 1)
ToggleRow(p, "Enabled", "Crosshair", "Enabled", 2)
SliderRow(p, "Size", "Crosshair", "Size", 4, 30, 3)
SliderRow(p, "Thickness", "Crosshair", "Thick", 1, 6, 4)
SliderRow(p, "Gap", "Crosshair", "Gap", 0, 20, 5)

p = MakePanel("Performance")
Section(p, "PERFORMANCE", 1)
ToggleRow(p, "Low-End Mode", "Performance", "Low", 2)
SliderRow(p, "Update Rate", "Performance", "Rate", 15, 120, 3)

p = MakePanel("UI")
Section(p, "INTERFACE", 1)
ToggleRow(p, "Blur Background", "UI", "Blur", 2)

p = MakePanel("Config")
Section(p, "CONFIGURATION", 1)

local rgbRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 36),
	BackgroundColor3 = C.Panel2,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	Parent = p,
})
New("UICorner", {CornerRadius = UDim.new(0, 7), Parent = rgbRow})
New("TextLabel", {
	Size = UDim2.new(1, -78, 1, 0),
	Position = UDim2.fromOffset(10, 0),
	BackgroundTransparency = 1,
	Text = "Rainbow RGB Theme",
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = C.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = rgbRow,
})

local rgbBtn = New("TextButton", {
	Size = UDim2.fromOffset(64, 24),
	Position = UDim2.new(1, -74, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = C.Accent,
	BackgroundTransparency = 0.25,
	Text = "OFF",
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = C.Text,
	AutoButtonColor = false,
	Parent = rgbRow,
})
New("UICorner", {CornerRadius = UDim.new(0, 5), Parent = rgbBtn})

----------------------------------------------------------------
-- Logic
----------------------------------------------------------------
function SwitchTab(id)
	if State.Tab == id then return end
	local old = State.Tab
	State.Tab = id

	if TabBtns[old] then
		Tw(TabBtns[old].Btn, {BackgroundTransparency = 1}, 0.15)
		Tw(TabBtns[old].Ind, {BackgroundTransparency = 1}, 0.15)
		Tw(TabBtns[old].Txt, {TextColor3 = C.Dim}, 0.15)
	end
	if TabBtns[id] then
		Tw(TabBtns[id].Btn, {BackgroundTransparency = 0.4}, 0.15)
		Tw(TabBtns[id].Ind, {BackgroundTransparency = 0}, 0.15)
		Tw(TabBtns[id].Txt, {TextColor3 = C.Text}, 0.15)
	end

	if Tabs[old] then Tabs[old].Visible = false end
	if Tabs[id] then
		Tabs[id].Visible = true
		Tabs[id].Position = UDim2.fromOffset(8, 0)
		Tw(Tabs[id], {Position = UDim2.fromOffset(0, 0)}, 0.18)
	end
end

function Toggle(open)
	State.Open = open
	if open then
		Main.Visible = true
		Main.Size = UDim2.fromOffset(720, 20)
		Main.BackgroundTransparency = 1
		Tw(Main, {Size = UDim2.fromOffset(720, 470), BackgroundTransparency = 0.04}, 0.28)
		if Settings.UI.Blur then
			if not State.Blur then
				State.Blur = New("BlurEffect", {Size = 0, Parent = Lighting})
			end
			Tw(State.Blur, {Size = 10}, 0.3)
		end
	else
		Tw(Main, {Size = UDim2.fromOffset(720, 20), BackgroundTransparency = 1}, 0.22).Completed:Connect(function()
			Main.Visible = false
		end)
		if State.Blur then Tw(State.Blur, {Size = 0}, 0.2) end
	end
end

local function SetRGB(on)
	if on then
		CFG.Theme = "RGB"
		rgbBtn.Text = "ON"
		if State.RGBConn then State.RGBConn:Disconnect() end
		State.RGBConn = RunService.RenderStepped:Connect(function(dt)
			State.Hue = (State.Hue + dt * CFG.RGBSpeed) % 1
			local col = Color3.fromHSV(State.Hue, 0.65, 1)
			C.Accent = col
			for _, t in pairs(TabBtns) do
				if t.Ind.BackgroundTransparency < 0.5 then t.Ind.BackgroundColor3 = col end
			end
			rgbBtn.BackgroundColor3 = col
		end)
	else
		CFG.Theme = "Dark"
		rgbBtn.Text = "OFF"
		if State.RGBConn then State.RGBConn:Disconnect() State.RGBConn = nil end
		C.Accent = Color3.fromRGB(115, 135, 255)
		rgbBtn.BackgroundColor3 = C.Accent
	end
end

rgbBtn.MouseButton1Click:Connect(function()
	SetRGB(CFG.Theme ~= "RGB")
end)

UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == CFG.OpenKey then
		Toggle(not State.Open)
	end
end)

-- start clean
SwitchTab("ESP")
Toggle(true) -- open immediately so you see it loaded
print("[UniversalPremium v2.5] loaded clean — RightShift to toggle")
