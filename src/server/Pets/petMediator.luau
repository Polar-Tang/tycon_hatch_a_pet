local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Egg = require(ServerScriptService.Pets.Egg.Egg)
local EggTypes = require(ServerScriptService.Pets.Egg.EggTypes)
local PetService = require(ServerScriptService.Pets.Pet.PetService)
local Registry = require(ServerScriptService.Pets.Registry.Registry)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local PetTypesContract = require(ReplicatedStorage.Pets.PetTypesContract)
local Constants = require(ReplicatedStorage.utils.Constants)
local utils = require(ReplicatedStorage.utils.utils)
local remotes = ReplicatedStorage.RemoteEvents

local BuyEggRemote: RemoteEvent = remotes.BuyEggRemote

BuyEggRemote.OnServerEvent:Connect(function(player: Player, color: string)
	if typeof(color) ~= "string" then
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

	-- optional: check currency here
	-- if not CurrencyService:CanAfford(player, color) then return end

	-- create egg domain object
	local egg = Egg.new(player, plot, our_egg_color, 10)

	-- random position inside plot
	local randPos = PlotService:GetRandPosition(plot)

	egg:CloneModel()
	egg:Spawn(randPos)
	egg:StartHatching()
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
		if not petSellContract.petData then
			return
		end

		local petLists = Registry:GetHandler(player)
		local petId = petSellContract.petData.petId
		local petStats = petLists:getPetStats(petId)
		if not petStats then
			warn(petSellContract.petData, " not found")
			return
		end

		local petRarity = petLists:getPetRarity(petId)

		local price = calculatePriceByStats(petStats, petRarity)
		petLists:removePet(petId)
		PetService.destroyPet(player, petId)

		local inventory = PlayerInventory:GetHandler(player)
		inventory:IncreaseMoney(price)
		ReplicatedStorage.RemoteEvents.PetNew:FireClient(player, petLists.pets)
	end
)

ReplicatedStorage.RemoteEvents.NPCFighter.OnServerEvent:Connect(function(a0: Player, ...)
	----print("IDK ")
end)

local CombatController = require(ServerScriptService.Pets.Pet.Combat.CombatController)

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
		print("Invalid teleport destination: ", teleportTo)
		return
	end

	local resolver = teleportDestinations[teleportTo]

	if not resolver then
		print("Not a valid destination: " .. tostring(teleportTo))
		return
	end

	local destination: CFrame? = resolver(player)
	if not destination then
		print("Could not resolve CFrame for: " .. tostring(teleportTo))
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
		print("data from client to server ", data)
		if data.destroy and posibleSession then
			teleport(a0, "plot")
			return
		elseif data.destroy and not posibleSession then
			print("send return with no session")
			return
		end
		local petId = data.petId
		local bossName = data.bossName

		local folderSession = CombatController.createAFightSession(a0, data)
		if not folderSession then
			return
		end

		local bestiaryHandler = Registry:GetHandler(a0)
		local pets_stats = bestiaryHandler:getPetStats(petId)

		do
			local petInformation = {
				healthVal = utils.HealthCalc(pets_stats.Health),
				meleeVal = utils.MeleeCalc(pets_stats.Melee),
				petId = petId,
			}
			local bossInformation = {
				healthVal = 500,
				meleeVal = 200,
				petId = bossName,
			}

			local fightInfo = {
				player_pet = petInformation,
				player_boss = bossInformation,
			}
			----print("fightInfo ", fightInfo)
			CombatController.initFightSession(a0, folderSession, fightInfo) --tag:telepor_point_croakan
			BossRemoteEvent:FireClient(a0, fightInfo)
		end

		local point_name = Constants.teleportPointSuffix .. string.lower(bossName)
		local teleportpoint: BasePart = workspace:WaitForChild(point_name)

		local character: Model = a0.Character or a0.CharacterAdded:Wait()
		character:PivotTo(teleportpoint.CFrame)
	end
)

-- This is the event that confirms the pét player can do the damage, all the health values should be instances that lives in the Replicated storage and the server handles it while the client only renders it
ReplicatedStorage.RemoteEvents.Attacks.OnServerEvent:Connect(function(player: Player, data)
	-- data is the state context coming from the client; it contains
	-- `npc` (the model performing the attack) and `enemy` among other
	-- fields.  we only care about the attacker name to know which
	-- health to decrement.

	local folderSession = CombatController.getPlayerSessionFolder(player)
	if not folderSession then
		warn("no combat session for player", player)
		return
	end

	local petFolder = folderSession:FindFirstChild("PlayerPet")
	local bossFolder = folderSession:FindFirstChild("PlayerBoss")
	if not petFolder or not bossFolder then
		warn("missing pet/boss folders in session for ", player)
		return
	end

	local petIdVal = petFolder:FindFirstChild("Id")
	local bossIdVal = bossFolder:FindFirstChild("Id")
	if not petIdVal or not bossIdVal then
		warn("session ids not registered")
		return
	end

	local targetHealth: IntValue
	local damage = 0

	if data.petId == petIdVal.Value then
		-- player's pet dealt damage to boss
		targetHealth = bossFolder:FindFirstChild("Health")

		-- rate limit the application of damage: don't allow hits more
		-- frequently than every 2 seconds on the same health value.
		local last = targetHealth:GetAttribute("LastAttack") or 0
		local now = os.time()
		if now - last <= 2 then
			----print("invalid interval time have passed")
			return
		end
		targetHealth:SetAttribute("LastAttack", now)

		-- compute pet damage from stats stored in registry
		local bestiaryHandler = Registry:GetHandler(player)
		local pets_stats = bestiaryHandler:getPetStats(petIdVal.Value)
		if pets_stats then
			damage = utils.MeleeCalc(pets_stats.Melee)
		else
			damage = 1
		end
	elseif data.petId == bossIdVal.Value then
		-- boss hit the pet; use a hard coded value for now
		targetHealth = petFolder:FindFirstChild("Health")
		damage = 200
	else
		-- attacker not part of this session
		return
	end

	if not targetHealth then
		return
	end
	ReplicatedStorage.RemoteEvents.TextFade:FireClient(player, {
		text = tostring(damage),
		position = data.position,
	})

	-- subtract and clamp to zero
	print("", targetHealth.Name, " health: ", targetHealth.Value)

	targetHealth.Value = math.max(targetHealth.Value - damage, 0)
	print("", targetHealth.Name, " new health: ", targetHealth.Value)
end)

return {}
