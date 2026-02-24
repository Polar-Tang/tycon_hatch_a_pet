local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Egg = require(ServerScriptService.Pets.Egg.Egg)
local EggTypes = require(ServerScriptService.Pets.Egg.EggTypes)
local PetService = require(ServerScriptService.Pets.Pet.PetService)
local Registry = require(ServerScriptService.Pets.Registry.Registry)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local PetTypesContract = require(ReplicatedStorage.Pets.PetTypesContract)
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
	local egg = Egg.new(player, plot, our_egg_color, 60)

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
	end
)
return {}
