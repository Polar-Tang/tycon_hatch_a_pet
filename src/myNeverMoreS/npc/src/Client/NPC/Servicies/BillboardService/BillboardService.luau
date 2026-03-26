local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Client.Binder.helpers.petData)
local utils = require(ReplicatedStorage.utils.utils)
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local BaseObject = require(ReplicatedStorage.Nevermore.Quenty.baseobject.Shared.BaseObject)

local module = setmetatable({}, BaseObject)
module.__index = module

function module.new(parent, maid, petInfo)
	local self = setmetatable({}, module)

	local petStats = petInfo.petStats
	local billboard = ReplicatedStorage.Nevermore.Custom.npc.src.Client.NPC.Overhead:Clone()

	-- resizes billboard

	local petName = parent:GetAttribute("petName")
	billboard.Frame.NpcName.Text = petName
	billboard.Frame.Rarity.Text = string.upper(petData[petName].rarity)
	billboard.Frame.Production.Text = MoneyLib.HandleMoney(math.round(utils.MoneyCalc(petStats.Stamina))) .. "/s"
	billboard.Adornee = parent.PrimaryPart
	billboard.Parent = parent.PrimaryPart

	maid:GiveTask(parent:GetAttributeChangedSignal("Stamina"):Connect(function()
		local Stamina: NumberValue = parent:GetAttribute("Stamina")

		billboard.Frame.Production.Text = MoneyLib.HandleMoney(math.round(utils.MoneyCalc(Stamina))) .. "/s"
	end))

	self.pet = parent
	self.billboard = billboard

	return self
end

local ORIGINAL_SIZE = UDim2.fromScale(9, 3)

function module:resizes()
	local current_billboard = self.billboard
	assert(current_billboard, " trying to resize pet billboard without initialize it")
	local modelSize = self.pet:GetExtentsSize()
	local magnitude = modelSize.Magnitude
	local scale_factor = math.log(magnitude) * 0.3

	local scale = 1 + scale_factor
	scale = math.clamp(scale, 1, 2.2)

	current_billboard.Size = UDim2.fromScale(ORIGINAL_SIZE.X.Scale * scale, ORIGINAL_SIZE.Y.Scale * scale)

	local current_pet_stats = petData[self.pet:GetAttribute("petName")]

	if current_pet_stats.adorneeOffset then
		current_billboard.StudsOffset = current_pet_stats.adorneeOffset * scale
	end
end

function module.resizeBillboard(pet): { Size: UDim2, StudsOffset: UDim2 }
	assert(pet, "resizeBillboard: pet is nil")

	local modelSize = pet:GetExtentsSize()
	local magnitude = modelSize.Magnitude
	local scale_factor = math.log(magnitude) * 0.3

	local scale = 1 + scale_factor
	scale = math.clamp(scale, 1, 2.2)

	local newSize = UDim2.fromScale(ORIGINAL_SIZE.X.Scale * scale, ORIGINAL_SIZE.Y.Scale * scale)

	local petName = pet:GetAttribute("petName")
	local current_pet_stats = petData[petName]
	local newStudsOffset = Vector3.new(0, 3, 0) * scale
	if current_pet_stats and current_pet_stats.adorneeOffset then
		newStudsOffset = current_pet_stats.adorneeOffset * scale
	end
	return {
		Size = newSize,
		StudsOffset = newStudsOffset,
	}
end

return module
