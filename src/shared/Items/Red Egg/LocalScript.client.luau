--!strict


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local previewHandler = require(ReplicatedStorage.Items.utils.previewHandler)


local tool = script.Parent :: Tool
local player = Players.LocalPlayer

local eggPreviewHandler: previewHandler.EggPreviewHandlerType? = nil

local function onEquip()
	if eggPreviewHandler then
		eggPreviewHandler:Destroy()
		eggPreviewHandler = nil
	end

	eggPreviewHandler = previewHandler.new(tool, player, "red")
end

local function onUnequip()
	if eggPreviewHandler then
		eggPreviewHandler:Destroy()
		eggPreviewHandler = nil
	end
end

tool.Equipped:Connect(onEquip)
tool.Unequipped:Connect(onUnequip)
