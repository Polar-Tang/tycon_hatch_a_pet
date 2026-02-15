local HttpService = game:GetService("HttpService")
local StarterPlayer = game:GetService("StarterPlayer")
local RunService = game:GetService("RunService")

local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local gearShop = require(StarterPlayer.StarterPlayerScripts.facade.gearShop)
local npcMap = {}

local kibly_name = "Kibly Shop Keeper"
local kibly_id = HttpService:GenerateGUID(false)

npcMap["Kibly Shop Keeper"] = {
	id = kibly_id,
	name = kibly_name,
	-- TODO: USE ACTUAL PATH TO NPC
	model = workspace:FindFirstChild("ShopKeepers"):FindFirstChild(kibly_name),
	promptTrigger = function()
		if RunService:IsServer() then
			return
		end
		gearShop.open()
		gearShop.createItem({
			image = assets["egg_icon"],
			title = "Egg",
			description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
			price = 100,
		})
		gearShop.createItem({
			image = assets["egg_icon"],
			title = "Egg 2",
			description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
			price = 100,
		})
	end,
}

return npcMap
