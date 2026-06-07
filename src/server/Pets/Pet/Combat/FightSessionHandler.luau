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
local PetAttacks = require(script.Parent.PetAttacks)
local combatInstanceRegistryFolder = ReplicatedStorage.Pets.Fights
local CombatTurn = ReplicatedStorage.RemoteEvents.CombatTurn

-- seconds before the first round, so clients can arm their turn listeners
local START_GRACE = 1

-- One fighter entry tracked by the session (a pet or the boss).
type Fighter = {
	id: string,
	petName: string,
	meleeVal: number,
	band: string,
	health: IntValue,
}

type PendingHit = {
	targetHealth: IntValue,
	damage: number,
}

type FightSessionHandler = {
	_folderSession: Folder,
	_maid: Maid.Maid,
	player: Player,
	pets: { Fighter },
	boss: Fighter,

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
		-- combat state
		pets = {},
		-- ability registries (stubbed effects, real structure)
		buffs = {}, -- [band] = { <buff/debuff> }
		traps = {}, -- pending traps consulted on the boss turn
		defense = 0, -- accumulated damage reduction for the boss turn
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
		table.insert(self.pets, {
			id = petInfo.petId,
			petName = petInfo.petName or petInfo.petId,
			meleeVal = petInfo.meleeVal,
			band = band,
			health = healthValue,
		})
		self.buffs[band] = {}
	end

	-- Boss
	do
		local player_boss = data.player_boss
		local bossHealth = FightSessionHandler._createFighterFolder(self._folderSession, "PlayerBoss", player_boss.petId, player_boss.healthVal)
		self.boss = {
			id = player_boss.petId,
			petName = player_boss.petName or player_boss.petId,
			meleeVal = player_boss.meleeVal,
			band = "PlayerBoss",
			health = bossHealth,
		}

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
	-- Defensive buffs only protect for the round they are cast in.
	self.defense = 0

	for index, pet in ipairs(self.pets) do
		if not self._running then
			return
		end
		if pet.health.Value > 0 then
			self:_tickEffects(pet)

			local isSpecial = index == self._specialIndex
			local attackSet = PetAttacks.get(pet.petName)
			local attack = isSpecial and attackSet.specialAttack or attackSet.basicAttack

			if isSpecial then
				self:_applySpecial(attack, pet)
			end

			self:_castAttack(pet, attack, self.boss.health, isSpecial, 0)
			task.wait(attack.duration)
		end

		if self.boss.health.Value <= 0 then
			break
		end
	end

	-- Boss turn — only if the boss is alive and the team isn't wiped.
	if self._running and self.boss.health.Value > 0 and self:_anyPetAlive() then
		local bossAttack = PetAttacks.getBoss(self.boss.petName).basicAttack
		self:_runTraps(bossAttack)
		local target = self:_firstAlivePet()
		if target then
			self:_castAttack(self.boss, bossAttack, target.health, false, self.defense)
			task.wait(bossAttack.duration)
		end
	end

	-- advance which pet casts its special next round
	if #self.pets > 0 then
		self._specialIndex = (self._specialIndex % #self.pets) + 1
	end

	-- end conditions
	if self.boss.health.Value <= 0 or not self:_anyPetAlive() then
		self._running = false
	end
end

--[=[
	Fires the "perform your attack" event to the client and registers a pending
	hit token. Does NOT write health — that happens in `ConfirmHit` once the
	client reports the animation hit landed.
]=]
function FightSessionHandler:_castAttack(attacker: Fighter, attack, targetHealth: IntValue, isSpecial: boolean, reduction: number)
	reduction = reduction or 0
	local base = (attack.damageMultiplier or 0) * (attacker.meleeVal or 0)
	local damage = math.max(0, math.floor(base - reduction))

	self._hitSeq += 1
	local token = self._hitSeq
	self._pendingHits[token] = {
		targetHealth = targetHealth,
		damage = damage,
	}

	CombatTurn:FireClient(self.player, {
		band = attacker.band,
		attackId = isSpecial and "specialAttack" or "basicAttack",
		animation = attack.animation,
		isSpecial = isSpecial or false,
		text = (attacker.petName or attacker.id) .. " " .. (attack.text or ""),
		damage = damage,
		token = token,
	} :: NpcFighterTypes.CombatTurnData)
end

--[=[
	Client confirmed the hit for `token`. Apply the stored damage once. Tokens
	that are never confirmed (attacker died mid-swing) are simply dropped on
	teardown, so there is no double counting.
]=]
function FightSessionHandler:ConfirmHit(token: number, position: Vector3?)
	local pending: PendingHit? = self._pendingHits[token]
	if not pending then
		return
	end
	self._pendingHits[token] = nil

	local health = pending.targetHealth
	if not health or not health.Parent then
		return
	end
	health.Value = math.max(0, health.Value - pending.damage)

	-- show the damage number at the spot the client reported the hit landed
	if position then
		ReplicatedStorage.RemoteEvents.TextFade:FireClient(self.player, {
			text = tostring(pending.damage),
			position = position,
		})
	end
end

--[=[
	Routes a special by its `kind`. Effects are stubbed (text only) but the
	plug-in surface is wired:
	- defensive → register a buff on the caster + bump the round's `defense`.
	- instant   → resolve now.
	- trap      → register a trap the boss turn consults.
]=]
function FightSessionHandler:_applySpecial(attack, caster: Fighter)
	local kind = attack.kind or "instant"

	if kind == "defensive" then
		self.buffs[caster.band] = self.buffs[caster.band] or {}
		table.insert(self.buffs[caster.band], { kind = "defensive", attack = attack })
		-- stub: real reduction value plugs in here
		self.defense += 0
	elseif kind == "trap" then
		table.insert(self.traps, { caster = caster, attack = attack })
	end
	-- instant resolves immediately; all numeric effects are stubbed for now

	if attack.apply then
		attack.apply(self, caster)
	end
end

-- Plays a pet's registered buffs/debuffs for the round (stub: structure only).
function FightSessionHandler:_tickEffects(pet: Fighter)
	local effects = self.buffs[pet.band]
	if not effects then
		return
	end
	for _, _effect in ipairs(effects) do
		-- stub: each effect's per-round behaviour plugs in here
	end
end

-- Consumes pending traps on the boss turn (stub: structure only).
function FightSessionHandler:_runTraps(_bossAttack)
	for index = #self.traps, 1, -1 do
		-- stub: trap trigger (reflect / block) plugs in here
		table.remove(self.traps, index)
	end
end

function FightSessionHandler:_anyPetAlive(): boolean
	for _, pet in ipairs(self.pets) do
		if pet.health.Value > 0 then
			return true
		end
	end
	return false
end

function FightSessionHandler:_firstAlivePet(): Fighter?
	for _, pet in ipairs(self.pets) do
		if pet.health.Value > 0 then
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
