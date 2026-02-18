--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local PetService = require(ServerScriptService.Pets.Pet.PetService)

local EggsFolder = ServerStorage:WaitForChild("Eggs")

export type EggColor = "red" | "green" | "blue" | "white"

export type EggData = {
	color: EggColor,
	time: number,
	model: Model?,
	player: Player,
	plot: BasePart,
}

local Egg = {}
Egg.__index = Egg

-- pet pools per egg color
local PetPools: { [EggColor]: { string } } = {
	white = { "Elephant", "Fox", "Panda", "Rhino", "Hippo" },
}

-- constructor
function Egg.new(player: Player, plot: BasePart, color: EggColor, hatchTime: number)
	assert(PetPools[color], "Invalid egg color")

	local self = setmetatable({} :: EggData, Egg)
	self.color = color
	self.time = hatchTime
	self.player = player
	self.plot = plot
	self.model = nil

	return self
end

-- clone egg model
function Egg:CloneModel(): Model
	local template = EggsFolder:FindFirstChild(self.color)
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

	assert(self.model)

	self.model:PivotTo(CFrame.new(position))
	self.model.Parent = workspace
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
	PetService.createPet(self.player, petName)

	-- destroy egg model
	if self.model then
		self.model:Destroy()
	end
end

return Egg
