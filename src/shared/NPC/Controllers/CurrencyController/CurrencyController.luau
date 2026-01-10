local RS = game:GetService("ReplicatedStorage")
local packages = RS.Nevermore.Quenty
local BaseObject = require(packages.baseobject.Shared.BaseObject)
-- TEST IF this doesn't break
local Amount: RemoteEvent = RS.RemoteEvents.Amount

local CurrencyController = setmetatable({}, BaseObject)
CurrencyController.__index = CurrencyController

function CurrencyController.new(data, serviceBag: any, player)
	local self = setmetatable(BaseObject.new() :: any, CurrencyController)
	local character = data.pet

	self._character = character
	self._root = character.PrimaryPart

	self._range = data.range
	self._serviceBag = serviceBag

	self._currentPlayer = nil
	self._humanoidTracker = nil

	self._player = player

	return self
end

function CurrencyController:getAnimHandler()
	local BinderProvider = self._serviceBag:GetService(_G.BinderProvider)

	-- local WeaponBinder = BinderProvider:Get("Armed")
	local AnimationBinder = BinderProvider:Get("AnimationHandler")
	self._AnimationHandler = AnimationBinder:Get(self._character)
end

function CurrencyController:GenerateCurrency()
	if not self._AnimationHandler then
		self:getAnimHandler()
	end
	-- BUG: if there are invited players this will be an issue because it also updates the amount of money thing

	Amount:FireAllClients({
		model = self._character,
		amount = 2,
	})
	self._AnimationHandler:LoadAnimation(true, "dizzy")
	print("self._player ", self._player)
end

function CurrencyController:StopAnim()
	if not self._AnimationHandler then
		return -- GenerateCurrency haven't be called yet
	end
	self._AnimationHandler:LoadAnimation(false, "dizzy")
	print("create the floating number that are at capture pet")
end

return CurrencyController
