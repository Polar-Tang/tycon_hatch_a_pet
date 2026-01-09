local require = require(script.Parent.loader).load(script)
-- local Binder = require("Binder")
local AnimationHandler = require("AnimationHandler")

local Animation = {}
Animation.ServiceName = "Animation"

function Animation.new(char: Model, serviceBag)
	local self = setmetatable(AnimationHandler.new(char, serviceBag), Animation)
	self._serviceBag = assert(serviceBag, "No serviceBag")
	return self
end

-- something like this should be don in the binder provider
-- https://quenty.github.io/NevermoreEngine/docs/servicebag#dependency-injection-in-binders
-- Binder.new("ANimationHandler", require(constructor))
return Animation