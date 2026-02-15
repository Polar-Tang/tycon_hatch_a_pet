-- nameToAction but in the server

local HttpService = game:GetService("HttpService")

local npcMap = {}

local kibly_name = "Kibly Shop Keeper"
local kibly_id = HttpService:GenerateGUID(false)

npcMap["Kibly Shop Keeper"] = {
	id = kibly_id,
	name = kibly_name,
	-- TODO: USE ACTUAL PATH TO NPC
	model = workspace:FindFirstChild("ShopKeepers"):FindFirstChild(kibly_name),
}

return npcMap
