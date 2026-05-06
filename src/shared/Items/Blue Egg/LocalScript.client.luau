--!strict


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local previewHandler = require(ReplicatedStorage.Items.utils.previewHandler)


local tool = script.Parent :: Tool
local player = Players.LocalPlayer

local eggPreviewHandler: previewHandler.EggPreviewHandlerType? = nil


local function onUnequip()
	local playerHumanod: Humanoid = (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid")
	if eggPreviewHandler then
		eggPreviewHandler:Destroy()
		eggPreviewHandler = nil
		playerHumanod:UnequipTools()
	end
end

local function onEquip()
	if eggPreviewHandler then
		eggPreviewHandler:Destroy()
		eggPreviewHandler = nil
	end

	eggPreviewHandler = previewHandler.new(tool, player, "white")
	eggPreviewHandler:ConnectBrio(onUnequip)

end

tool.Equipped:Connect(onEquip)
tool.Unequipped:Connect(onUnequip)
