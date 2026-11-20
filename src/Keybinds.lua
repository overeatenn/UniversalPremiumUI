-- Keybind manager
local UserInputService = game:GetService("UserInputService")
local Keybinds = {}
local Theme, State, Components
local KeyNames = {}

for _, k in pairs(Enum.KeyCode:GetEnumItems()) do
	KeyNames[k] = k.Name
end

function Keybinds.Init(theme, state, components)
	Theme = theme
	State = state
	Components = components
end

function Keybinds.Name(key)
	return KeyNames[key] or tostring(key)
end

function Keybinds.BindListener(featureKey, keyBtn, notifyFn)
	keyBtn.MouseButton1Click:Connect(function()
		State.KeybindListening = featureKey
		keyBtn.Text = "..."
		Components.Tween(keyBtn, {BackgroundColor3 = Theme.Warn}, 0.12)
		if notifyFn then notifyFn("Press a key...", Theme.Warn) end
	end)
end

function Keybinds.ModeCycle(featureKey, modeBtn, notifyFn)
	modeBtn.MouseButton1Click:Connect(function()
		local order = {"Toggle", "Hold", "Press"}
		local feat = State.Features[featureKey]
		local idx = table.find(order, feat.Mode) or 1
		idx = idx % #order + 1
		feat.Mode = order[idx]
		modeBtn.Text = feat.Mode
		if notifyFn then notifyFn(featureKey .. " → " .. feat.Mode, Theme.Accent) end
	end)
end

function Keybinds.StartInput(notifyFn, onToggleUI)
	UserInputService.InputBegan:Connect(function(inp, gp)
		if gp then return end

		if State.KeybindListening and inp.UserInputType == Enum.UserInputType.Keyboard then
			local fk = State.KeybindListening
			State.Features[fk].Key = inp.KeyCode
			State.KeybindListening = nil
			if notifyFn then notifyFn("Bound to " .. Keybinds.Name(inp.KeyCode), Theme.Success) end
			return
		end

		if inp.KeyCode == Enum.KeyCode.RightShift then
			if onToggleUI then onToggleUI() end
			return
		end

		for name, feat in pairs(State.Features) do
			if feat.Key == inp.KeyCode then
				if feat.Mode == "Toggle" then
					feat.Enabled = not feat.Enabled
					if notifyFn then notifyFn(name .. (feat.Enabled and " on" or " off"), feat.Enabled and Theme.Success or Theme.Dim) end
				elseif feat.Mode == "Hold" then
					feat.Enabled = true
					State.Held[name] = true
				elseif feat.Mode == "Press" then
					feat.Enabled = true
					if notifyFn then notifyFn(name .. " pressed", Theme.Accent) end
					task.delay(0.12, function() feat.Enabled = false end)
				end
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(inp)
		for name, feat in pairs(State.Features) do
			if feat.Key == inp.KeyCode and feat.Mode == "Hold" and State.Held[name] then
				feat.Enabled = false
				State.Held[name] = nil
			end
		end
	end)
end

return Keybinds
