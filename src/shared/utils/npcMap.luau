-- nameToAction but in the server

local HttpService = game:GetService("HttpService")

local function InitNpc(model: Model, animId: string, npcId: string)
	local animator: Animator = model:WaitForChild("Humanoid"):WaitForChild("Animator")

	local cheerAnimation: Animation = Instance.new("Animation")
	cheerAnimation.AnimationId = animId
	local anim_track: AnimationTrack = animator:LoadAnimation(cheerAnimation)
	anim_track:Play()

	local prompt = Instance.new("ProximityPrompt")
	-- prompt.Style = Enum.ProximityPromptStyle.Default
	prompt.ActionText = "Shop"
	prompt.Name = "Shop"
	prompt.ObjectText = npcId
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 24
	prompt.ClickablePrompt = true
	prompt.Parent = model
end

local npcMap = {}

local kibly_name = "Kibly Shop Keeper"
local kibly_id = HttpService:GenerateGUID(false)

local kibly_shop_keeper = workspace:FindFirstChild("ShopKeepers"):FindFirstChild(kibly_name)

npcMap[kibly_name] = {
	id = kibly_id,
	name = kibly_name,
	-- TODO: USE ACTUAL PATH TO NPC
	model = kibly_shop_keeper,
	init = function()
		InitNpc(kibly_shop_keeper, "http://www.roblox.com/asset/?id=507766666", kibly_id)
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
}

return npcMap
