local Roact = require(game.ReplicatedStorage.Roact)
local Players = game:GetService("Players")

local src = script
local MainAppUI = require(src.MainApp)
local ctx = src.Context
local PromptProvider = require(ctx.PromptContext.PromptProvider)

--local StarterGui: StarterGui = game:GetService("StarterGui")

--StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight

local App = Roact.Component:extend("App")

function App:render()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
	}, {

		PromptProvider = Roact.createElement(PromptProvider, {}, {
			AppUI = Roact.createElement(MainAppUI),
		}),
	})
end

local PlayerGui = Players.LocalPlayer.PlayerGui
Roact.mount(Roact.createElement(App), PlayerGui, "UI")

return {}
