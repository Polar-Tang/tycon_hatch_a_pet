local StarterPlayer = game:GetService("StarterPlayer")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)

export type nameToAction = {
	image: string,
	greetings: (selfParent: Model) -> (),
	imageSize: UDim2,
}

local module = {}

module["Kibly Shop Keeper"] = {
	image = assets["store_icon"],
	greetings = function(selfParent: Model)
		local animator: Animator = selfParent:WaitForChild("Humanoid"):WaitForChild("Animator")

		local cheerAnimation = Instance.new("Animation")
		cheerAnimation.AnimationId = "http://www.roblox.com/asset/?id=507770677"
		animator:LoadAnimation(cheerAnimation):Play()
	end,
	imageSize = UDim2.fromOffset(128, 86),
}

return module :: { [string]: nameToAction }
