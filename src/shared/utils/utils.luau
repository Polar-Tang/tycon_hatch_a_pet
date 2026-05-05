local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local testPart = require(script.Parent.testPart)
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

local utils = {}

utils.filter = function(tbl, predicate)
	local filtered = {}

	for key, value in pairs(tbl) do
		if predicate(value, key) then
			table.insert(filtered, value)
		end
	end

	return filtered
end

utils.ScaleToLvl = function(npc: Model, LVL: number)
	local baseScale = 1
	local growthPerLevel = 0.007 -- 0.0134 * 150 = 2.01

	local scale = baseScale + growthPerLevel * (LVL - 1)
	npc:ScaleTo(scale)
end

utils.fixPetY = function(model: Model, root: BasePart)
	-- local cf, size = model:GetBoundingBox()

	local rootY = root.Position.Y

	local groundOffset = rootY - root.Size.Y / 2
	return root.Position.Y
end

function utils.CastRay(origin: Vector3, direction: Vector3): RaycastResult?
	local params: RaycastParams = RaycastParams.new()
	params.FilterDescendantsInstances = CollectionService:GetTagged("NPC")
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.CollisionGroup = "NPCs"

	local result = Workspace:Raycast(origin, direction, params)

	if not result then
		return nil -- no ground found
	end
	return result
end

function utils.GetGroundYPosition(model: Model, rayHeight: number, rayDepth: number)
	assert(model.PrimaryPart, "Model must have a PrimaryPart")

	local primaryPart = model.PrimaryPart
	-- Start ray above the pet
	-- 1.325

	-- Get model bounding box
	local _, size = model:GetBoundingBox()

	local origin = primaryPart.Position + Vector3.new(0, rayHeight, 0)
	local direction = Vector3.new(0, -rayDepth, 0)

	local result = utils.CastRay(origin, direction)

	-- Calculate correct Y (ground + half height)
	local correctedY = result.Position.Y
	print("is failing the correctedY ? ", correctedY)
	return correctedY, result
end

function utils.ArrangeYPosition(model: Model, position: Vector3?)
	local y = utils.GetGroundYPosition(model, 20, 100)
	local root = model.PrimaryPart
	local currentPos = position or root.Position

	if y then
		local newPosition = Vector3.new(currentPos.X, y, currentPos.Z)
		model:MoveTo(newPosition)
	end
end

utils.MoneyCalc = function(stamina)
	local staminaGT1 = stamina
	if stamina == 0 then
		staminaGT1 = 1
	end
	return (staminaGT1 ^ 1.8) * 2
end

utils.HealthCalc = function(health)
	return 50 + (50 * health)
end

utils.MeleeCalc = function(melee)
	return 100 + (10 * melee)
end

utils.setUpStats = function(model, stats)
	local melee = stats.Melee
	local stamina = stats.Stamina
	local health = stats.Health

	model:SetAttribute("Melee", utils.MeleeCalc(melee))
	model:SetAttribute("Health", utils.HealthCalc(health))
	model:SetAttribute("Stamina", stamina)
end

utils.GenerateRandStats = function(LVL)
	local statsMap = {
		0,
		0,
		0,
	}

	while LVL > 0 do
		LVL -= 1
		local rand = math.random(1, 3)
		statsMap[rand] += 1
	end
	return {
		["Health"] = statsMap[1],
		["Melee"] = statsMap[2],
		["Stamina"] = statsMap[3],
	}
end

utils.GetModelHeight = function(model: Model): number
	-- local lowestPart: BasePart?
	-- local highestPart: BasePart?

	-- for _, part in ipairs(model:GetDescendants()) do
	-- 	if part:IsA("BasePart") then
	-- 		if not lowestPart or part.Position.Y - part.Size.Y / 2 < lowestPart.Position.Y - lowestPart.Size.Y / 2 then
	-- 			lowestPart = part
	-- 		end
	-- 		if
	-- 			not highestPart
	-- 			or part.Position.Y + part.Size.Y / 2 > highestPart.Position.Y + highestPart.Size.Y / 2
	-- 		then
	-- 			highestPart = part
	-- 		end
	-- 	end
	-- end

	-- if not lowestPart or not highestPart then
	-- 	return 0
	-- end

	-- local bottomOfLowest = lowestPart.Position.Y - lowestPart.Size.Y / 2
	-- local topOfHighest = highestPart.Position.Y + highestPart.Size.Y / 2

	local height = model:GetExtentsSize().Y
	return height
end

utils.getPercentage = function(T, fr)
	--[[
					1000 -> 100
					200  -> (200*100)/1000
					
					100 -> 1000
					0.5 -> 100/(1000*0.5)
				]]
	return T * fr / 100
end

utils.bossCoins = function(cash)
	--[[
					1000 -> 100
					200  -> (200*100)/1000
					
					100 -> 1000
					0.5 -> 100/(1000*0.5)
				]]
	return utils.getPercentage(cash, 15)
end

utils.getPetRarity = function(petName: PetTypes.petNames)
	if not petData[petName] then
		return
	end
	return petData[petName].rarity
end

return utils
