--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local npcUtils = require(ReplicatedStorage.utils.npcUtils)
local Incomes = require(ReplicatedStorage.Nevermore.Custom.values.src.Server.Incomes)
local PetsByClassification = require(ReplicatedStorage.Pets.PetsByClassification)
local PetsByRarity = require(ReplicatedStorage.Pets.PetsByRarity)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local types = require(ReplicatedStorage.utils.types)
local EggTypes = require(script.Parent.EggTypes)
local rngUtils = require(script.Parent.rng.rngUtils)
local PetService = require(ServerScriptService.Pets.Pet.PetService)

local EggsFolder = ReplicatedStorage.Items.Templates.Eggs
type EggColor = EggTypes.EggColor
type rarity = PetTypes.rarity
type petNames = PetTypes.petNames
type classification = "Carnivore" | "Herbivore"

local Egg = {}
Egg.__index = Egg

local EggColorToRarity: { [string]: rarity } = {
	white = "common",
	blue = "rare",
	purple = "epic",
	orange = "legendary",
}

local EggColorToClassification: { [string]: classification } = {
	red = "Carnivore",
	green = "Herbivore",
}

-- constructor
function Egg.new(player: Player, plot: BasePart, color: EggColor, hatchTime: number)
	assert(EggColorToRarity[color] or EggColorToClassification[color], "Invalid egg color")

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

	self.model.Parent = workspace
	self.model:MoveTo(position)
	self.position = position
	local billboardContract: types.billBoardContract = {
		componentName = "ProgresBar",
		model = self.model,
		duration = self.time
	}
	npcUtils.createBillboard(self.model, billboardContract)
end

-- start hatching timer
function Egg:StartHatching()
	task.delay(self.time, function()
		self:Hatch()
	end)
end

-- hatch logic
function Egg:Hatch()
	local incomes = Incomes:GetHandler(self.player)
	if not incomes then
		return
	end

	local eggDropFactor = incomes:GetEggFactor()
	local drop = rngUtils.getDrop(eggDropFactor)
	print("Random drop: " .. drop)
	print("Luck: " ..eggDropFactor)
	local rarity = rngUtils.getRarity(drop)
	print("Rarity: " .. rarity )

	local petsSameRarity: { petNames }?
	local classification = EggColorToClassification[self.color]
	if classification then
		petsSameRarity = PetsByClassification[classification][rarity]
	else
		local mappedRarity: rarity? = EggColorToRarity[self.color]
		if mappedRarity then
			petsSameRarity = PetsByRarity[mappedRarity]
		end
	end

	if not petsSameRarity or #petsSameRarity == 0 then
		warn("No pets available for egg color", self.color, "and rarity", rarity)
		return
	end

	local index = math.random(1, #petsSameRarity)
	local petName = petsSameRarity[index]
	
	PetService.createPet(self.player, petName, self.position)
	
	-- destroy egg model
	if self.model then
		self.model:Destroy()
	end
end

return Egg
