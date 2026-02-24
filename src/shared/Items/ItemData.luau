local StarterPlayer = game:GetService("StarterPlayer")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local itemTypes = require(StarterPlayer.StarterPlayerScripts.facade.itemTypes)
local itemData = {} :: { [string]: itemTypes.itemData }

itemData["SpeedCoil"] = {
	image = assets["egg_icon"],
	title = "Speed Coil",
	description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
	price = 0,
	itemName = "SpeedCoil",
	template = game.ReplicatedStorage:WaitForChild("Items"):WaitForChild("Templates"):WaitForChild("SpeedCoil"),
	createPivot = function()
		local modelCFrame = CFrame.new(1, 1, 0)

		return modelCFrame * CFrame.Angles(0, math.rad(315), 0)
	end,
	cameraRotation = function(modelCFrame, modelSize)
		local distance = math.max(modelSize.X, modelSize.Y, modelSize.Z) * 0.8

		return CFrame.new(1, 1, 0)
			* CFrame.new(0, 0, -distance)
			* CFrame.Angles(math.rad(180), math.rad(350), math.rad(180))
	end,
}

itemData["White_Egg"] = {
	image = assets["egg_icon"],
	title = "White Egg",
	description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
	template = game.ReplicatedStorage
		:WaitForChild("Items")
		:WaitForChild("Templates")
		:WaitForChild("Eggs")
		:WaitForChild("white"),
	price = 0,
	createPivot = function(modelCFrame)
		return CFrame.new(1, 1, 0)
	end,
	cameraRotation = function(modelCFrame, modelSize)
		local distance = math.max(modelSize.X, modelSize.Y, modelSize.Z) * 1.2

		return CFrame.new(1, 1, 0) * CFrame.new(0, 0, -distance) * CFrame.Angles(math.rad(180), 0, math.rad(180))
	end,
}

return itemData
