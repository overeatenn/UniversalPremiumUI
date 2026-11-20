-- UniversalPremiumUI v4.1 Loader
-- Multi-module Novoline-style shell

local HttpService = game:GetService("HttpService")
local BASE = "https://raw.githubusercontent.com/overeatenn/UniversalPremiumUI/main/src/"

local function fetch(path)
	local ok, res = pcall(function()
		return game:HttpGet(BASE .. path)
	end)
	if not ok or not res or #res < 10 then
		warn("[UP] failed to fetch " .. path)
		return nil
	end
	return res
end

local function run(src, name)
	if not src then return nil end
	local fn, err = loadstring(src, name)
	if not fn then
		warn("[UP] compile error in " .. name .. ": " .. tostring(err))
		return nil
	end
	local ok, result = pcall(fn)
	if not ok then
		warn("[UP] runtime error in " .. name .. ": " .. tostring(result))
		return nil
	end
	return result
end

-- Bootstrap order
local Theme      = run(fetch("Theme.lua"), "Theme")
local State       = run(fetch("State.lua"), "State")
local Components  = run(fetch("Components.lua"), "Components")
local Keybinds    = run(fetch("Keybinds.lua"), "Keybinds")

if not (Theme and State and Components and Keybinds) then
	warn("[UniversalPremium] module load failed — aborting")
	return
end

-- Inject shared refs
Components.Init(Theme, State)
Keybinds.Init(Theme, State, Components)

-- Pages
local HomePage     = run(fetch("Pages/Home.lua"), "Home")
local CommandsPage = run(fetch("Pages/Commands.lua"), "Commands")
local PlayersPage  = run(fetch("Pages/Players.lua"), "Players")
local ScriptsPage  = run(fetch("Pages/Scripts.lua"), "Scripts")
local SettingsPage = run(fetch("Pages/Settings.lua"), "Settings")

if HomePage then HomePage.Init(Theme, State, Components) end
if CommandsPage then CommandsPage.Init(Theme, State, Components, Keybinds) end
if PlayersPage then PlayersPage.Init(Theme, State, Components) end
if ScriptsPage then ScriptsPage.Init(Theme, State, Components) end
if SettingsPage then SettingsPage.Init(Theme, State, Components) end

-- Main shell
local Main = run(fetch("Main.lua"), "Main")
if Main then
	Main.Init({
		Theme = Theme,
		State = State,
		Components = Components,
		Keybinds = Keybinds,
		Pages = {
			Home = HomePage,
			Commands = CommandsPage,
			Players = PlayersPage,
			Scripts = ScriptsPage,
			Settings = SettingsPage,
		}
	})
end

print("[UniversalPremium v4.1] multi-module shell ready — RightShift")
