local StarterPlayer = game:GetService("StarterPlayer")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)

export type nameToAction = {
	image: string,
	greetings: (selfParent: Model) -> (),
}

local module = {}

module["Kibly Shop Keeper"] = {
	image = assets["store_icon"],
	greetings = function(selfParent)
		print("hello, i am " .. selfParent.Name)
	end,
}

return module :: { [string]: nameToAction }
