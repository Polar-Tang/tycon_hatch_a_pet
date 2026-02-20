-- nameToAction but in the server

local HttpService = game:GetService("HttpService")
local npcUtils = require(script.Parent.npcUtils)

local function InitNpc(model: Model, animId: string, npcId: string)
	local animator: Animator = model:WaitForChild("Humanoid"):WaitForChild("Animator")

	local cheerAnimation: Animation = Instance.new("Animation")
	cheerAnimation.AnimationId = animId
	local anim_track: AnimationTrack = animator:LoadAnimation(cheerAnimation)
	anim_track:Play()
	print("IS THIS set up BEFORE THE triggering frontend?")

	npcUtils.createProximityPrompt(model, {
		npcId = npcId,
		Name = "Shop",
		ActionText = "Shop",
	})
end

local npcMap = {}

local kibly_name = "Kibly Shop Keeper"
local kibly_id = HttpService:GenerateGUID(false)

local kibly_shop_keeper = workspace:FindFirstChild("ShopKeepers"):FindFirstChild(kibly_name)

export type NpcEntry = {
	id: string,
	name: string,
	model: Model,
	init: () -> (),
	get_prompty: () -> ProximityPrompt?,
}

npcMap[kibly_name] = {
	id = kibly_id,
	name = kibly_name,
	-- TODO: USE ACTUAL PATH TO NPC
	model = kibly_shop_keeper,
	init = function()
		InitNpc(kibly_shop_keeper, "http://www.roblox.com/asset/?id=507766666", kibly_id)
	end,
	get_prompty = function()
		return kibly_shop_keeper:FindFirstChild(kibly_id)
	end,
}

local egg_name = "Egg Shop Keeper"
local Egg_id = HttpService:GenerateGUID(false)

local Egg_shop_keeper = workspace:FindFirstChild("ShopKeepers"):FindFirstChild(egg_name)

npcMap[egg_name] = {
	id = Egg_id,
	name = egg_name,
	-- TODO: USE ACTUAL PATH TO NPC
	model = Egg_shop_keeper,
	init = function()
		InitNpc(Egg_shop_keeper, "http://www.roblox.com/asset/?id=507766388", Egg_id)
	end,
	get_prompty = function()
		return Egg_shop_keeper:FindFirstChild(Egg_id)
	end,
}

return npcMap :: { [string]: NpcEntry }
