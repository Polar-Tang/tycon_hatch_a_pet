local StarterPlayer = game:GetService("StarterPlayer")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local itemData = {}

itemData["SpeedCoil"] = {
	image = assets["egg_icon"],
	title = "Speed Coil",
	description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
	price = 100,
	itemName = "SpeedCoil",
}

return itemData
