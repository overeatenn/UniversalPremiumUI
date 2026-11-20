-- Shared runtime state
local State = {
	Open = true,
	ActivePage = "Home",
	KeybindListening = nil,
	Hue = 0,
	RGB = false,
	RGBConn = nil,
	Blur = nil,
	Features = {
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
	},
	Held = {},
}

return State
