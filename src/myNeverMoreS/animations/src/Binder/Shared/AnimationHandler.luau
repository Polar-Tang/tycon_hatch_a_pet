--[[
Animation handler @v_04
	The .new accepts an object as a parameter, it tolerates the model player or the player object
	Check the animation priority before stop it
	Got bindable events for animations
Animation handler @v_03
	implements Lazy load on registered animations
Animation handler @v_04
	Added Init method for animationContainer, supports AnimationController and Humanoid.Animator
	Requires Init to be called before using other methods
]]
local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
--local NeverMore = require(RS.Packages.neverMore.loader).load(script.Parent.Parent.Parent.Packages.neverMore)
--local Binder = NeverMore("Binder")
--print("binder ", Binder)
local AnimationHandler = {}
AnimationHandler.__index = AnimationHandler
type MaidType = typeof(Maid.new(...))

export type AnimationsData = {
	animationId: string,
	AnimationTrack: AnimationTrack,
	--AnimationPriorityNumber: number -- i'm not sure if this is useful
}

export type AnimationMap = {
	[string]: { Animation },
}

export type Options = {
	player: Player?,
	char: Model?,
	animations: AnimationMap?,
	armName: string?,
}

--[[
local PRIORITY_LIST = {
	Enum.AnimationPriority.Core,
	Enum.AnimationPriority.Idle,
	Enum.AnimationPriority.Movement,
	Enum.AnimationPriority.Action,
	Enum.AnimationPriority.Action2,
	Enum.AnimationPriority.Action3,
	Enum.AnimationPriority.Action4,
}
]]
type AnimationDescriptor = {
	Animation: Animation,
	AnimationTrack: AnimationTrack,
	Maid: MaidType,
	preloaded: boolean,
}

type AnimationDescriptors = {
	[string]: AnimationDescriptor,
}

export type AnimationHandlerType = {
	Char: Model,
	animations: AnimationMap,
	animationDescriptors: AnimationDescriptors,
	armName: string,
	_maid: MaidType,
	_initialized: boolean,
	animator: Animator,
	Init: (self: AnimationHandlerType, animationContainer: Instance) -> (),
	LoadAnimation: (self: AnimationHandlerType, state: boolean, animaName: string, isPreload: boolean?) -> AnimationTrack?,
	AddAnimations: (self: AnimationHandlerType, newAnims: AnimationMap) -> (),
	Restart: (self: AnimationHandlerType) -> (),
	Destroy: (self: AnimationHandlerType) -> (),
	registryAnims: (self: AnimationHandlerType, anims: AnimationMap) -> (),
	preloadAll: (self: AnimationHandlerType) -> (),
	OnSignal: (self: AnimationHandlerType, info: connArgs) -> (),
	PreloadAnims: (self: AnimationHandlerType, animsName: { string }) -> (),
	ClearAllTheAnims: (self: AnimationHandlerType) -> (),
}

function AnimationHandler.new(char, serviceBag): Options
	local self = setmetatable({}, AnimationHandler)
	self.Char = char
	self.animations = {}
	self.animationDescriptors = {}
	self.armName = ""
	self._maid = Maid.new()
	self._initialized = false
	return self
end

function AnimationHandler:Init(animationContainer: Instance)
	assert(not self._initialized, "Already initialized")
	if animationContainer:IsA("AnimationController") then
		self.animator = (animationContainer :: any).Animator
	elseif animationContainer:IsA("Humanoid") then
		self.animator = (animationContainer :: any).Animator
	else
		error("animationContainer must be AnimationController or Humanoid")
	end
	self._initialized = true
end

--[[
If takes state false does nothing, returns nil
If takes state false and animation name, stop it, returns nil
If takes state true and animation name, play it, returns AnimationTrack
If takes state true and animation name and preload true, playr and stop it inmediatly, returns nil
]]
function AnimationHandler:LoadAnimation(state: boolean, animaName: string, isPreload: boolean)
	assert(self._initialized, "Must call Init first")
	---- START ANIM ----
	--print("self.animationDescriptors ", self.animationDescriptors)
	if isPreload then
		warn("Do you meant to use Preload() " .. debug.traceback())
	end
	local current_desc = self:_getDescriptor(animaName)
	self:_ensurePreload(animaName)
	local animaTionTrack: AnimationTrack = current_desc.AnimationTrack

	if state and not animaTionTrack then
		local newanimaTionTrack = self.animator:LoadAnimation(self.animationDescriptors[animaName].Animation)
		newanimaTionTrack:Play()
		self.animationDescriptors[animaName].AnimationTracker = newanimaTionTrack
		return animaTionTrack
	elseif state and animaTionTrack then
		animaTionTrack:Play()
		return animaTionTrack
	end
	--------------------------------------

	---- STOP ANIM ----
	if not state and animaTionTrack then
		animaTionTrack:Stop()
		return nil
	elseif not state then
		return nil
	end
	return nil
	---- STOP ANIM ----
end

-- Check if there's an animator in case the user is ragdolled
function AnimationHandler:_Check()
	if not self.animator then
		return
	end
end

function AnimationHandler:_initDescriptior(animaName: string)
	local desc = self:_getDescriptor(animaName)
	local animId = self.animations[animaName]

	if desc.AnimationTrack then
		warn("This descriptor were intialized " .. debug.traceback())
	end
	local descriptor: AnimationDescriptor = {} :: AnimationDescriptor
	local newAnimation = Instance.new("Animation")
	newAnimation.AnimationId = animId
	descriptor.Animation = newAnimation
	descriptor.Maid = Maid.new()
	self.animationDescriptors[animaName] = descriptor
end

-- Declare the firast animation track and set ptreload to true in the descriptor
function AnimationHandler:_ensurePreload(animaName)
	if self.animationDescriptors[animaName].preloaded then
		return
	end
	self:_initDescriptior(animaName)

	-- Load the animation and declare it
	do
		local animaTionTrack: AnimationTrack =
			self.animator:LoadAnimation(self.animationDescriptors[animaName].Animation)
		animaTionTrack:Play()
		animaTionTrack:Stop()
		self.animationDescriptors[animaName].AnimationTrack = animaTionTrack
	end

	self.animationDescriptors[animaName].preloaded = true
end

-- Just a helper to getting the animation tracker by its animation name
function AnimationHandler:_getDescriptor(animaName): AnimationDescriptor
	assert(animaName, "Animation name is nil")
	assert(self.animations[animaName], animaName .. " animation name does not exists")
	return self.animationDescriptors[animaName]
end

function AnimationHandler:AddAnimations(newAnims)
	assert(self._initialized, "Must call Init first")
	for k, v in pairs(newAnims) do
		self.animations[k] = v
	end
end

function AnimationHandler:Restart()
	assert(self._initialized, "Must call Init first")
	self._maid:DoCleaning()
	self:ClearAllTheAnims()
end

function AnimationHandler:Destroy()
	assert(self._initialized, "Must call Init first")
	self._maid:DoCleaning()
	self:ClearAllTheAnims()
	setmetatable(self, nil)
end

function AnimationHandler:registryAnims(anims: AnimationMap)
	assert(self._initialized, "Must call Init first")
	self.animations = anims
	self:_declarDescriptors()
end

function AnimationHandler:_declarDescriptors()
	local newDescs = {}
	for k, _ in pairs(self.animations) do
		local descriptor = {}

		descriptor.Animation = nil
		descriptor.AnimationTrack = nil
		descriptor.Maid = nil
		descriptor.preloaded = false
		newDescs[k] = descriptor
	end
	self.animationDescriptors = newDescs
end

-- Preaload all the animation at once, better don't use it on long animations list
function AnimationHandler:preloadAll()
	assert(self._initialized, "Must call Init first")
	warn(debug.traceback())
	local anims = self.animations
	-- local descriptors = {} :: { AnimationDescriptors }

	for k, v in pairs(anims) do
		local descriptor: AnimationDescriptor = {} :: AnimationDescriptor
		local newAnimation = Instance.new("Animation")
		newAnimation.AnimationId = v
		descriptor.Animation = newAnimation
		descriptor.Maid = Maid.new()
		descriptor.preloaded = true
		self.animationDescriptors[k] = descriptor
		self:LoadAnimation(true, k, true)
	end

	--self.animationDescriptors = descriptors
end

type connArgs = {
	callback: (Track: AnimationTrack, params: any) -> (),
	animationName: string,
	animationEventName: string,
	override: boolean?,
}

-- TODO:  for a future project, chage this name to OnAnimationEvent
function AnimationHandler:OnSignal(info: connArgs)
	assert(self._initialized, "Must call Init first")
	local animName = info.animationName
	local animationEventName = info.animationEventName
	local override = info.override
	local descriptor: AnimationDescriptor = self.animationDescriptors[animName]

	local animationTracker = descriptor.AnimationTrack
	local signal: RBXScriptSignal
	if descriptor.Maid[animationEventName] and not override then
		return
	elseif descriptor.Maid[animationEventName] and override then
		descriptor.Maid[animationEventName]:Disconnect()
	end

	if animationEventName == "EndedCon" then
		signal = animationTracker.Ended
	else
		signal = animationTracker:GetMarkerReachedSignal(animationEventName)
	end

	local conn = signal:Connect(function(param)
		info.callback(animationTracker, param)
	end)
	descriptor.Maid:__newindex(animationEventName, conn)
end

function AnimationHandler:PreloadAnims(animsName: { string })
	assert(self._initialized, "Must call Init first")
	for _, name in ipairs(animsName) do
		self:_ensurePreload(name)
	end
end

function AnimationHandler:_ClearAnimation(animName)
	local desc = self.animationDescriptors[animName]
	if desc and desc.Maid then
		desc.Maid:DoCleaning() -- disconnects ALL marker/ended/start connections
		if desc.AnimationTrack then
			desc.AnimationTrack:Destroy()
		end
	end
end
function AnimationHandler:ClearAllTheAnims()
	assert(self._initialized, "Must call Init first")
	for k, v in pairs(self.animations) do
		self:_ClearAnimation(k)
	end
end
export type AnimationHandler = AnimationHandlerType

return AnimationHandler
