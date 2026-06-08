local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local Incomes = require(ReplicatedStorage.Nevermore.Custom.values.src.Server.Incomes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local utils = require(ReplicatedStorage.utils.utils)
local PetBase = require(script.Parent.PetBase)
local PlayerPet = require(script.Parent.PlayerPet)
local Boss = require(script.Parent.Boss)
local combatInstanceRegistryFolder = ReplicatedStorage.Pets.Fights
local CombatTurn = ReplicatedStorage.RemoteEvents.CombatTurn

-- seconds before the first round, so clients can arm their turn listeners
local START_GRACE = 1

-- A registered pending hit: which fighter it lands on and how much (already
-- mitigated by the target). Health is written when the client confirms.
type PendingHit = {
	target: PetBase.PetBase,
	damage: number,
}

type FightSessionHandler = {
	_folderSession: Folder,
	_maid: Maid.Maid,
	player: Player,
	pets: { PlayerPet.PlayerPet },
	boss: Boss.Boss,
	_byBand: { [string]: PetBase.PetBase },

	new: (player: Player) -> FightSessionHandler,
	GetHealth: (self: FightSessionHandler, nameInstance: string) -> IntValue?,
	Destroy: (self: FightSessionHandler) -> (),
}

local FightSessionHandler = {}
FightSessionHandler.__index = FightSessionHandler

function FightSessionHandler.new(player: Player): FightSessionHandler?
	local folder = FightSessionHandler._createFolder(player)
	if not folder then
		warn("Error creating folder")
		return nil
	end

	local self = setmetatable({
		_folderSession = folder,
		_maid = Maid.new(),
		-- combat state: an ordered team (for the round loop) + a band lookup (for
		-- routing a confirmed hit back to the fighter it landed on). Each fighter's
		-- buff/debuff/defense/trap registries now live on the fighter itself.
		pets = {},
		_byBand = {}, -- [band] = PetBase (pet or boss)
		_specialIndex = 1, -- which pet casts its special this round (rotates)
		_running = false,
		_started = false,
		-- decoupling of round cadence (server-timed) from damage (client-confirmed)
		_pendingHits = {}, -- [token] = PendingHit
		_hitSeq = 0,
	}, FightSessionHandler)

	return self
end

function FightSessionHandler._createFolder(player: Player): Folder?
	local instanceName = tostring(player.UserId)
	if combatInstanceRegistryFolder:FindFirstChild(instanceName) then
		print("player can be in a single instance at a single time")
		return nil
	end
	local newFolder = Instance.new("Folder", combatInstanceRegistryFolder)
	newFolder.Name = player.UserId
	return newFolder
end

-- Builds a session folder child holding the `Id`/`Health` values a fighter renders.
function FightSessionHandler._createFighterFolder(parent: Folder, band: string, id: string, healthVal: number): IntValue
	local fighterFolder = Instance.new("Folder", parent)
	fighterFolder.Name = band

	local idVal = Instance.new("StringValue", fighterFolder)
	idVal.Value = id
	idVal.Name = "Id"

	local healthValue = Instance.new("IntValue", fighterFolder)
	healthValue:SetAttribute("MaxHealth", healthVal)
	healthValue.Value = healthVal
	healthValue.Name = "Health"

	return healthValue
end

function FightSessionHandler.Init(self: FightSessionHandler, player: Player, data: NpcFighterTypes.FightInfo)
	self.player = player

	local playerRegistrer = Instance.new("StringValue", self._folderSession)
	playerRegistrer.Name = "PlayerId"
	playerRegistrer.Value = tostring(player.UserId)

	-- Player pets (ordered). Band index aligns with the "PlayerPetN" naming the
	-- client uses to address each health value.
	for index, petInfo in ipairs(data.player_pets) do
		local band = "PlayerPet" .. index
		local healthValue = FightSessionHandler._createFighterFolder(self._folderSession, band, petInfo.petId, petInfo.healthVal)
		local pet = PlayerPet.new(self, {
			id = petInfo.petId,
			petName = petInfo.petName or petInfo.petId,
			meleeVal = petInfo.meleeVal,
			band = band,
			health = healthValue,
		})
		table.insert(self.pets, pet)
		self._byBand[band] = pet
	end

	-- Boss
	do
		local player_boss = data.player_boss
		local bossHealth = FightSessionHandler._createFighterFolder(self._folderSession, "PlayerBoss", player_boss.petId, player_boss.healthVal)
		self.boss = Boss.new(self, {
			id = player_boss.petId,
			petName = player_boss.petName or player_boss.petId,
			meleeVal = player_boss.meleeVal,
			band = "PlayerBoss",
			health = bossHealth,
		})
		self._byBand["PlayerBoss"] = self.boss

		-- reward the player when the boss falls (unchanged behaviour, generalized name)
		self._maid:GiveTask(bossHealth.Changed:Connect(function(a0: number)
			if a0 <= 0 then
				local incomes = Incomes:GetHandler(player)
				local extraReward = incomes:GetExtraCoins()
				local inventory = PlayerInventory:GetHandler(player)
				ReplicatedStorage.RemoteEvents.Notifier:FireClient(player, {
					notification = player_boss.petId .. " has fallen.",
				})

				local moneyEarned = utils.bossCoins(inventory.cash)
				local maybeDoubled = incomes:GetDoubleCoins()
				if maybeDoubled then
					moneyEarned = maybeDoubled
					ReplicatedStorage.RemoteEvents.Notifier:FireClient(player, {
						notification = "[Elephant Bonus]: coins doubled " .. MoneyLib.HandleMoney(moneyEarned) .. "!",
					})
				else
					ReplicatedStorage.RemoteEvents.Notifier:FireClient(player, {
						notification = "You earn " .. MoneyLib.HandleMoney(moneyEarned) .. " coins!",
					})
				end

				if extraReward > 0 then
					inventory:IncreaseMoney(extraReward)
					extraReward = math.round(extraReward)
					ReplicatedStorage.RemoteEvents.Notifier:FireClient(player, {
						notification = "[Pig Bonus]: You gained " .. MoneyLib.HandleMoney(extraReward),
					})
				end
			end
		end))
	end
end

--[=[
	Kicks off the turn-based round loop. The cadence is server-timed (each attack
	consumes its own `duration`); damage is applied later when the client confirms
	the hit (see `ConfirmHit`). Runs on its own coroutine so it never yields the
	main task. Idempotent.
]=]
function FightSessionHandler:StartRounds()
	if self._started then
		return
	end
	self._started = true
	self._running = true

	self._maid:GiveTask(function()
		self._running = false
	end)

	task.spawn(function()
		-- grace period: the fighters' state machines arm their CombatTurn listeners
		-- a frame after they enter Combat, so don't fire the first turn instantly.
		task.wait(START_GRACE)
		while self._running do
			self:_runRound()
			-- yield a frame so a fully-resolved round can't spin tight
			task.wait()
		end
	end)
end

function FightSessionHandler:_runRound()
	for index, pet in ipairs(self.pets) do
		if not self._running then
			return
		end
		if pet:IsAlive() then
			pet:TickEffects()

			local isSpecial = index == self._specialIndex
			local attack = pet:SelectAttack(isSpecial)

			if isSpecial then
				pet:ApplySpecial(attack)
			end

			self:_castTurn(pet, attack, isSpecial)
			task.wait(attack.duration)
		end

		if not self.boss:IsAlive() then
			break
		end
	end

	-- Boss turn — only if the boss is alive and the team isn't wiped.
	if self._running and self.boss:IsAlive() and self:_anyPetAlive() then
		local bossAttack = self.boss:SelectAttack(false)
		self.boss:RunTraps()
		self:_castTurn(self.boss, bossAttack, false)
		task.wait(bossAttack.duration)
	end

	-- advance which pet casts its special next round
	if #self.pets > 0 then
		self._specialIndex = (self._specialIndex % #self.pets) + 1
	end

	-- end conditions
	if not self.boss:IsAlive() or not self:_anyPetAlive() then
		self._running = false
	end
end

--[=[
	Asks the attacker for its outgoing damage and targets, has each target
	mitigate the hit with its own private defense, registers a pending hit, and
	fires "perform your attack" to the client. Does NOT write health — that
	happens in `ConfirmHit` once the client reports the animation hit landed.
]=]
function FightSessionHandler:_castTurn(attacker: PetBase.PetBase, attack, isSpecial: boolean)
	local damage, targets = attacker:CastAttack(attack, isSpecial)

	for _, target in ipairs(targets) do
		local finalDamage = target:Apply(damage)
		local token = self:_pend(target, finalDamage)

		CombatTurn:FireClient(self.player, {
			band = attacker.band,
			attackId = isSpecial and "specialAttack" or "basicAttack",
			animation = attack.animation,
			isSpecial = isSpecial or false,
			text = (attacker.petName or attacker.id) .. " " .. (attack.text or ""),
			damage = finalDamage,
			token = token,
		} :: NpcFighterTypes.CombatTurnData)
	end
end

-- Registers a pending hit and returns its token. The session owns the token
-- counter (trivially unique) and routes the confirmed hit back to its target.
function FightSessionHandler:_pend(target: PetBase.PetBase, damage: number): number
	self._hitSeq += 1
	local token = self._hitSeq
	self._pendingHits[token] = {
		target = target,
		damage = damage,
	}
	return token
end

--[=[
	Client confirmed the hit for `token`. Hand the stored damage to the target
	fighter, which writes its own health once. Tokens that are never confirmed
	(attacker died mid-swing) are simply dropped on teardown, so there is no
	double counting.
]=]
function FightSessionHandler:ConfirmHit(token: number, position: Vector3?)
	local pending: PendingHit? = self._pendingHits[token]
	if not pending then
		return
	end
	self._pendingHits[token] = nil

	pending.target:TakeDamage(pending.damage, position)
end

function FightSessionHandler:_anyPetAlive(): boolean
	for _, pet in ipairs(self.pets) do
		if pet:IsAlive() then
			return true
		end
	end
	return false
end

function FightSessionHandler:_firstAlivePet(): PetBase.PetBase?
	for _, pet in ipairs(self.pets) do
		if pet:IsAlive() then
			return pet
		end
	end
	return nil
end

function FightSessionHandler:GetHealth(nameInstance: NpcFighterTypes.healthBarId): IntValue?
	if typeof(nameInstance) ~= "string" then
		return nil
	end
	local target = self._folderSession:FindFirstChild(nameInstance)
	if not target then
		return nil
	end
	return target:FindFirstChild("Health")
end

function FightSessionHandler:Destroy()
	self._running = false
	self._maid:DoCleaning()
	local playerId = self._folderSession:FindFirstChild("PlayerId")
	if playerId then
		local player = Players:GetPlayerByUserId(playerId.Value)
		game.ReplicatedStorage.RemoteEvents.BossRemoteEvent:FireClient(player, { destroy = true })
	end
	self._folderSession:Destroy()
end

return FightSessionHandler
