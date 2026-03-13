local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

local TopButtons = {}

local global_maid = Maid.new()

export type buttons_cb = {
	["PlotButton"]: () -> (),
	["EggButton"]: () -> (),
	["UtilityButton"]: () -> (),
}

function TopButtons.init(buttons_cb: buttons_cb)
	for buttonName, cb in pairs(buttons_cb) do
		local plot_button: ImageButton = screen.TopButtons:FindFirstChild(buttonName)
		local plot_con = plot_button.Activated:Connect(cb)
		global_maid:GiveTask(plot_con)
	end
end

return TopButtons
