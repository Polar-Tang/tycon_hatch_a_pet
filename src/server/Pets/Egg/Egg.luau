--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local npcUtils = require(ReplicatedStorage.utils.npcUtils)
local EggTypes = require(script.Parent.EggTypes)
local PetService = require(ServerScriptService.Pets.Pet.PetService)

local EggsFolder = ReplicatedStorage.Items.Templates.Eggs
type EggColor = EggTypes.EggColor

local Egg = {}
Egg.__index = Egg

-- pet pools per egg color
local PetPools: { [EggColor]: { string } } = {
	white = { "Elephant", "Fox", "Panda", "Rhino", "Hippo" },
	red = { "Dog", "Cat", "Lion" },
}

-- constructor
function Egg.new(player: Player, plot: BasePart, color: EggColor, hatchTime: number)
	assert(PetPools[color], "Invalid egg color")

	local self = setmetatable({} :: EggTypes.EggData, Egg)
	self.color = color
	self.time = hatchTime
	self.player = player
	self.plot = plot
	self.model = nil

	return self
end

-- clone egg model
function Egg:CloneModel(): Model
	local template = EggsFolder:FindFirstChild(string.lower(self.color))
	assert(template, `Egg model for color {self.color} not found`)

	local clone = template:Clone()
	self.model = clone

	return clone
end

-- place egg in world
function Egg:Spawn(position: Vector3)
	if not self.model then
		self:CloneModel()
	end

	self.position = position

	-- Do no why the egg is placed weird
	local YFixed = Vector3.new(position.X, position.Y + 1.030, position.Z)
	assert(self.model)

	self.model:PivotTo(CFrame.new(YFixed))
	self.model.Parent = workspace
	npcUtils.createBillboard(self.model, {
		componentName = "ProgresBar",
		npc = self.model,
	})
	print("sent create billboard")
end

-- start hatching timer
function Egg:StartHatching()
	task.delay(self.time, function()
		self:Hatch()
	end)
end

-- hatch logic
function Egg:Hatch()
	local petCategories = PetPools[self.color]
	if not petCategories then
		return
	end

	local index = math.random(1, #petCategories)
	local petName = petCategories[index]
	local petData = petData[petName]
	if not petData then
		print("wtf?")
		return
	end
	local position = PetService.fixPetYFromPLayer(self.player, petName)
	local newPos = Vector3.new(self.position.X, position.Y, self.position.Z)
	PetService.createPet(self.player, petName, newPos)
	-- destroy egg model
	if self.model then
		self.model:Destroy()
	end
end

return Egg
