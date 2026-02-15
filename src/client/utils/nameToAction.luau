local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local ItemData = require(ReplicatedStorage.Items.ItemData)
local npcUtils = require(ReplicatedStorage.utils.npcUtils)
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local gearShop = require(StarterPlayer.StarterPlayerScripts.facade.gearShop)

export type nameToAction = {
	image: string,
	greetings: (selfParent: Model) -> (),
	imageSize: UDim2,
	promptTrigger: () -> (),
}

local module = {}

module["Kibly Shop Keeper"] = {
	image = assets["store_icon"],
	greetings = function(selfParent: Model)
		npcUtils.lookAtPlayer(selfParent)

		local animator: Animator = selfParent:WaitForChild("Humanoid"):WaitForChild("Animator")

		local cheerAnimation = Instance.new("Animation")
		cheerAnimation.AnimationId = "http://www.roblox.com/asset/?id=507770677"
		local anim_track: AnimationTrack = animator:LoadAnimation(cheerAnimation)
		anim_track:Play()
		local animEnded: RBXScriptConnection
		animEnded = anim_track.Ended:Connect(function(...)
			anim_track:Stop()

			animEnded:Disconnect()
		end)
	end,
	promptTrigger = function()
		gearShop.open()
		gearShop.createItem(ItemData["SpeedCoil"])
	end,
	imageSize = UDim2.fromOffset(128, 86),
}

return module :: { [string]: nameToAction }
