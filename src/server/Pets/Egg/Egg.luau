--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local npcUtils = require(ReplicatedStorage.utils.npcUtils)
local Incomes = require(ReplicatedStorage.Nevermore.Custom.values.src.Server.Incomes)
local EggsByColor = require(ReplicatedStorage.Pets.EggsByColor)
local PetsByClassificationArray = require(ReplicatedStorage.Pets.PetsByClassificationArray)
local PetsByRarity = require(ReplicatedStorage.Pets.PetsByRarity)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local Constants = require(ReplicatedStorage.utils.Constants)
local types = require(ReplicatedStorage.utils.types)
local utils = require(ReplicatedStorage.utils.utils)
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

local eggByModel: { [Model]: any } = {}

function Egg.getByModel(model: Model)
	return eggByModel[model]
end

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
	self.model.Name = "Egg"
	self.model:SetAttribute(Constants.EggCategory, self.color)
	eggByModel[clone] = self
	return clone
end

-- place egg in world
function Egg:Spawn(position: Vector3)
	if not self.model then
		self:CloneModel()
	end

	for _, descendant in self.model:GetDescendants() do
		if descendant:IsA("BasePart") then
			CollectionService:AddTag(descendant, Constants.PetArrangeExclue)
			descendant.CollisionGroup = "Npcs"
		end
	end

	self.model.Parent = Workspace
	self.model:MoveTo(position)
	CollectionService:AddTag(self.model, Constants.PetArrangeExclue)

	self.position = position
	local billboardContract: types.billBoardContract = {
		componentName = "ProgresBar",
		model = (self.model::any),
		duration = self.time,
	}
	npcUtils.createBillboard((self.model::any), billboardContract)
end

-- start hatching timer
function Egg:StartHatching()
	self.startTime = tick()
	task.delay(self.time, function()
		if not self.model then
			return
		end

		self.model:SetAttribute(Constants.playerEggId, (self.player :: Player).UserId)
		CollectionService:AddTag(self.model, Constants.hatchEgg)
	end)
end

-- hatch logic
function Egg:Hatch()
	local incomes = Incomes:GetHandler(self.player)
	if not incomes then
		return
	end

	if tick() - (self.startTime :: number) < self.time then
		return
	end

	local eggDropFactor = incomes:GetEggFactor()
	local drop = rngUtils.getDrop(eggDropFactor)
	local rarity = rngUtils.getRarity(drop)

	local petsSameRarity: { petNames }?
	local eggData = EggsByColor[self.color]
	if eggData and eggData.classification then
		petsSameRarity = PetsByClassificationArray[eggData.classification][rarity]
	elseif eggData and eggData.rarity then
		petsSameRarity = PetsByRarity[eggData.rarity]
	end

	if not petsSameRarity or #petsSameRarity == 0 then
		warn("No pets available for egg color", self.color, "and rarity", rarity)
		return
	end

	local index = math.random(1, #petsSameRarity)
	local petName = petsSameRarity[index]

	local pos = Vector3.new(self.position.X, Constants.GroundY, self.position.Z)
	PetService.createPet(self.player, petName, pos)

	-- destroy egg model
	if self.model then
		eggByModel[self.model] = nil
		self.model:Destroy()
	end
end

return Egg
