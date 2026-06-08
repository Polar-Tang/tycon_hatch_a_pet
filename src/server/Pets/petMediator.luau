local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Egg = require(ServerScriptService.Pets.Egg.Egg)
local EggTypes = require(ServerScriptService.Pets.Egg.EggTypes)
local PetService = require(ServerScriptService.Pets.Pet.PetService)
local Registry = require(ReplicatedStorage.Nevermore.Custom.bestiary.src.Server.BestiaryList)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local PetTypesContract = require(ReplicatedStorage.Pets.PetTypesContract)
local Constants = require(ReplicatedStorage.utils.Constants)
local utils = require(ReplicatedStorage.utils.utils)
local remotes = ReplicatedStorage.RemoteEvents

local BuyEggRemote: RemoteEvent = remotes.BuyEggRemote
local HatchEggRemote: RemoteEvent = remotes:WaitForChild("HatchEgg") :: RemoteEvent

BuyEggRemote.OnServerEvent:Connect(function(player: Player, data: { color: string, position: Vector3, itemId: string })
	local color = data.color
	local itemId = data.itemId

	if typeof(color) ~= "string" then
		return
	end

	if typeof(itemId) ~= "string" or itemId == "" then
		return
	end

	local our_egg_color = "blue" :: EggTypes.EggColor
	if EggTypes.isEggColor(color) then
		our_egg_color = color
	else
		return
	end

	-- ensure player has a plot
	local plot = PlotService.GetPlotByUserId(tostring(player.UserId))
	if not plot then
		warn("Player has no plot")
		return
	end

	local position = data.position
	
	local isValidPos = PlotService.IsPositionInsideFenceBounds(plot, position)
	if not isValidPos then 
		return
	end

	local inventory = PlayerInventory:GetHandler(player)
	if not inventory then
		return
	end

	local inventoryItem = inventory.items[itemId]
	if not inventoryItem then
		return
	end

	

	local expectedItemName = EggTypes.expectedItemNameByColor[our_egg_color]
	if expectedItemName and inventoryItem.itemName ~= expectedItemName then
		warn("Item color mismatch", player, itemId, color, inventoryItem.itemName)
		return
	end

	local removedItem = inventory:RemoveItemById(itemId)
	if not removedItem then
		warn("Could not consume egg item", player, itemId)
		return
	end
	-- optional: check currency here
	-- if not CurrencyService:CanAfford(player, color) then return end

	-- create egg domain object
	local egg = Egg.new(player, plot, our_egg_color, 3)

	

	egg:CloneModel()
	egg:Spawn(position)
	egg:StartHatching()
end)

HatchEggRemote.OnServerEvent:Connect(function(player: Player, eggModel: Instance, startTime: number)
	if not eggModel or not eggModel:IsA("Model") then
		return
	end

	if typeof(startTime) ~= "number" then
		return
	end

	if eggModel:GetAttribute(Constants.playerEggId) ~= player.UserId then
		return
	end

	local egg = Egg.getByModel(eggModel)
	if not egg then
		return
	end

	local delaySeconds = math.max(0, (startTime + 5) - workspace:GetServerTimeNow())
	task.delay(delaySeconds, function()
		egg:Hatch()
	end)
end)

local function calculatePriceByStats(petStats: PetTypes.petStats, petRarity: PetTypes.rarity)
	local sum = 1
	for statName, petStat in pairs(petStats) do
		-- local stat = if petStat == 0 then 1 else petStat
		sum = sum + petStat
	end

	type rarityM = {
		[PetTypes.rarity]: number,
	}
	local rarirty_multiplier: rarityM = {
		["common"] = 1.0,
		["uncommon"] = 1.1,
		["rare"] = 1.2,
		["epic"] = 1.3,
		["legendary"] = 1.4,
	}

	-- local price = reduce * rarirty_multiplier[petRarity]
	local base = sum * 400
	-- todo: remove this if statement
	local price = base ^ (if rarirty_multiplier[petRarity] then rarirty_multiplier[petRarity] else 1.0)
	return price
end

ReplicatedStorage.RemoteEvents.PetSell.OnServerEvent:Connect(
	function(player: Player, petSellContract: PetTypesContract.PetSell)
		if not petSellContract then
			return
		end

		local petData = petSellContract.petData
		if not petData then
			return
		end

		local petLists = Registry:GetHandler(player)
		local petId = petData.petId
		local petStats = petLists:getPetStats(petId)
		if not petStats then
			warn(petData, " not found")
			return
		end

		local petRarity = utils.getPetRarity(petData.petName)

		local price = calculatePriceByStats(petStats, petRarity)
		petLists:removePet(petId)
		PetService.destroyPet(player, petId)

		local inventory = PlayerInventory:GetHandler(player)
		inventory:IncreaseMoney(price)
		ReplicatedStorage.RemoteEvents.PetNew:FireClient(player, { allPets = petLists.pets })
	end
)

local CombatController = require(ServerScriptService.Pets.Pet.Combat.CombatController)

-- A fighter binder reports that combat has actually started (its prompt was
-- triggered). Kick off the server-driven round loop; StartRounds is idempotent,
-- so the boss + every pet firing this is harmless.
ReplicatedStorage.RemoteEvents.NPCFighter.OnServerEvent:Connect(function(a0: Player, ...)
	CombatController.startRounds(a0)
end)

local SpawnEggShop = workspace:WaitForChild("SpawnEggShop")
local SpawnKiblyShop = workspace:WaitForChild("SpawnKiblyShop")

local teleportDestinations = {
	eggShop = function(_player)
		return SpawnEggShop.CFrame
	end,
	kiblyShop = function(_player)
		return SpawnKiblyShop.CFrame
	end,
	plot = function(player)
		return PlotService.GetSpawnPlot(player)
	end,
}
type teleportDestinations = "eggShop" | "kiblyShop" | "plot"
local checkDestination = function(destination: string): boolean
	if destination == "eggShop" or destination == "kiblyShop" or destination == "plot" then
		return true
	else
		return false
	end
end

local function teleport(player: Player, teleportTo: teleportDestinations)
	if typeof(teleportTo) ~= "string" then
		warn("Invalid teleport destination: ", teleportTo)
		return
	end

	local resolver = teleportDestinations[teleportTo]

	if not resolver then
		warn("Not a valid destination: " .. tostring(teleportTo))
		return
	end

	local destination: CFrame? = resolver(player)
	if not destination then
		warn("Could not resolve CFrame for: " .. tostring(teleportTo))
		return
	end

	local character = player.Character
	if not character then
		return
	end

	character:PivotTo(destination)
	CombatController.destroyFightSession(player)
end

game.ReplicatedStorage.RemoteEvents.TeleportRemote.OnServerEvent:Connect(
	function(player: Player, teleportTo: teleportDestinations)
		local isValid = checkDestination(teleportTo)
		if isValid then
			teleport(player, teleportTo)
		else
			print("Invalid teleport destination: ", teleportTo)
		end
	end
)

-- This is the event triggered on boss teleport, it confirms player can go to the instance, register it, teleport the player to the instance and tell the client to create all the npcs that just lives in the client
local BossRemoteEvent = ReplicatedStorage.RemoteEvents.BossRemoteEvent
BossRemoteEvent.OnServerEvent:Connect(
	function(a0: Player, data: NpcFighterTypes.combatInstanceData & { destroy: boolean? })
		local posibleSession = CombatController.getPlayerSessionFolder(a0)
		if data.destroy and posibleSession then
			teleport(a0, "plot")
			return
		elseif data.destroy and not posibleSession then
			warn("send return with no session")
			return
		end
		-- The client sends an ordered team (`petIds`). `petId` is still accepted for
		-- back-compat and wrapped into a one-element team.
		local petIds = data.petIds
		if (not petIds or #petIds == 0) and data.petId then
			petIds = { data.petId }
		end
		if not petIds or #petIds == 0 then
			warn("no pets provided for fight")
			return
		end

		local bossName = data.bossName

		local folderSession = CombatController.createAFightSession(a0, data)
		if not folderSession then
			return
		end

		local bestiaryHandler = Registry:GetHandler(a0)

		do
			-- Validate each id against what the player owns, cap at 3, keep order.
			local player_pets = {}
			for _, petId in ipairs(petIds) do
				if #player_pets >= 3 then
					break
				end
				-- ownership: pets are keyed by petId; getPetStats indexes a controller
				-- that only exists for owned pets, so gate on the registry first.
				local petInfo = bestiaryHandler.pets[petId]
				if not petInfo then
					warn("player does not own pet ", petId)
					continue
				end
				local pets_stats = bestiaryHandler:getPetStats(petId)
				if not pets_stats then
					continue
				end
				table.insert(player_pets, {
					petId = petId,
					petName = petInfo and petInfo.petName or petId,
					healthVal = utils.HealthCalc(pets_stats.Health),
					meleeVal = utils.MeleeCalc(pets_stats.Melee),
				})
			end

			if #player_pets == 0 then
				warn("no owned pets to fight with")
				CombatController.destroyFightSession(a0)
				return
			end

			local bossInformation = {
				healthVal = 3000,
				meleeVal = 200,
				petId = bossName,
				petName = bossName,
			}

			local fightInfo = {
				player_pets = player_pets,
				player_boss = bossInformation,
			}
			----print("fightInfo ", fightInfo)
			CombatController.initFightSession(a0, fightInfo) --tag:telepor_point_croakan
			BossRemoteEvent:FireClient(a0, fightInfo)
		end

		local point_name = Constants.teleportPointSuffix .. string.lower(bossName)
		local teleportpoint: BasePart = workspace:WaitForChild(point_name)

		local character: Model = a0.Character or a0.CharacterAdded:Wait()
		character:PivotTo(teleportpoint.CFrame)
	end
)

-- The client confirms that an attack animation's hit landed. The damage was
-- computed and stored server-side when the turn was cast, so here we just hand
-- the token back to the session, which applies the authoritative subtraction.
ReplicatedStorage.RemoteEvents.Attacks.OnServerEvent:Connect(function(player: Player, data)
	if typeof(data) ~= "table" then
		return
	end
	CombatController.confirmHit(player, data.hitToken, data.position)
end)

return {}
