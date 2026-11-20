-- Main shell orchestrator
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Main = {}

function Main.Init(deps)
	local Theme = deps.Theme
	local State = deps.State
	local Components = deps.Components
	local Keybinds = deps.Keybinds
	local Pages = deps.Pages

	local LP = Players.LocalPlayer
	if not LP then return end
	local PlayerGui = LP:WaitForChild("PlayerGui", 8)
	if not PlayerGui then return end

	pcall(function()
		local old = PlayerGui:FindFirstChild("UniversalPremium")
		if old then old:Destroy() end
	end)

	local Gui = Components.New("ScreenGui", {
		Name = "UniversalPremium",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		Parent = PlayerGui,
	})

	-- Status host
	local StatusHost = Components.New("Frame", {
		Size = UDim2.fromOffset(280, 36),
		Position = UDim2.new(0.5, 0, 1, -90),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Parent = Gui,
	})

	local function notify(text, color)
		Components.Notify(StatusHost, text, color)
	end

	-- Bottom nav
	local Nav = Components.New("Frame", {
		Name = "Nav",
		Size = UDim2.fromOffset(420, 48),
		Position = UDim2.new(0.5, 0, 1, -28),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = Gui,
	})
	Components.New("UICorner", {CornerRadius = UDim.new(0, 14), Parent = Nav})
	Components.New("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = Nav})
	Components.Shadow(Nav, 12, 0.55)
	Components.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		Parent = Nav,
	})
	Components.New("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = Nav})

	local NavButtons = {}
	local PageFrames = {}

	local function switchPage(id)
		if State.ActivePage == id then return end
		local old = State.ActivePage
		State.ActivePage = id

		if NavButtons[old] then
			Components.Tween(NavButtons[old].Btn, {BackgroundTransparency = 1}, 0.15)
			Components.Tween(NavButtons[old].Txt, {TextColor3 = Theme.Dim}, 0.15)
		end
		if NavButtons[id] then
			Components.Tween(NavButtons[id].Btn, {BackgroundTransparency = 0.35}, 0.15)
			Components.Tween(NavButtons[id].Txt, {TextColor3 = Theme.Text}, 0.15)
		end

		if PageFrames[old] then PageFrames[old].Visible = false end
		if PageFrames[id] then PageFrames[id].Visible = true end
	end

	local function makeNav(id, label)
		local b = Components.New("TextButton", {
			Name = id,
			Size = UDim2.fromOffset(62, 36),
			BackgroundColor3 = Theme.Elevated,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Parent = Nav,
		})
		Components.New("UICorner", {CornerRadius = UDim.new(0, 10), Parent = b})
		local txt = Components.New("TextLabel", {
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
				Components.Tween(b, {BackgroundTransparency = 0.6}, 0.12)
				Components.Tween(txt, {TextColor3 = Theme.Text}, 0.12)
			end
		end)
		b.MouseLeave:Connect(function()
			if State.ActivePage ~= id then
				Components.Tween(b, {BackgroundTransparency = 1}, 0.12)
				Components.Tween(txt, {TextColor3 = Theme.Dim}, 0.12)
			end
		end)
		b.MouseButton1Click:Connect(function() switchPage(id) end)
		NavButtons[id] = {Btn = b, Txt = txt}
	end

	makeNav("Home", "Home")
	makeNav("Commands", "Cmds")
	makeNav("Players", "Players")
	makeNav("Scripts", "Scripts")
	makeNav("Settings", "Settings")

	local function toggleUI()
		State.Open = not State.Open
		for _, p in pairs(PageFrames) do
			p.Visible = State.Open and (p.Name == State.ActivePage)
		end
		Nav.Visible = State.Open
		notify(State.Open and "UI opened" or "UI closed · RightShift", State.Open and Theme.Accent or Theme.Dim)
	end

	-- Build pages
	if Pages.Home then
		local page, fpsLbl, countLbl = Pages.Home.Build(Gui, switchPage, toggleUI)
		PageFrames.Home = page
		-- FPS loop
		task.spawn(function()
			local frames, last = 0, tick()
			RunService.RenderStepped:Connect(function()
				frames += 1
				if tick() - last >= 1 then
					fpsLbl.Text = frames .. " FPS"
					frames = 0
					last = tick()
				end
			end)
		end)
	end
	if Pages.Commands then
		local page = Pages.Commands.Build(Gui, notify)
		PageFrames.Commands = page
	end
	if Pages.Players then
		PageFrames.Players = Pages.Players.Build(Gui)
	end
	if Pages.Scripts then
		PageFrames.Scripts = Pages.Scripts.Build(Gui)
	end
	if Pages.Settings then
		PageFrames.Settings = Pages.Settings.Build(Gui)
	end

	Keybinds.StartInput(notify, toggleUI)

	-- Boot
	switchPage("Home")
	if not State.Blur then
		State.Blur = Instance.new("BlurEffect", Lighting)
		State.Blur.Size = 0
		Components.Tween(State.Blur, {Size = 10}, 0.4)
	end
	notify("Universal Premium v4.1 loaded", Theme.Accent)
end

return Main
