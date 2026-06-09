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

-- placeholder gesture (no real attack animation yet) and fallback pacing for an
-- ability that doesn't specify its own `duration`
local DEFAULT_ANIMATION = "eat"
local DEFAULT_DURATION = 3

-- A registered pending hit: which fighter it lands on, how much (already mitigated
-- by the target), and optional text to float instead of the number. Health is
-- written when the client confirms.
type PendingHit = {
	target: PetBase.PetBase,
	damage: number,
	fadeText: string?,
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

		-- announce each pet's passive once, now that the client is listening: this
		-- alerts the player, paints the passive's Health attribute (icon), and runs
		-- any one-time onStart boost (team health, melee, the boss armor break).
		for _, pet in ipairs(self.pets) do
			pet:ApplyPassive(self)
		end

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
			-- the ability callback runs the whole turn (fire + pacing) via the
			-- session primitives; the round loop only decides basic vs special
			if index == self._specialIndex then
				pet:SpecialAttack(self)
			else
				pet:BasicAttack(self)
			end
			-- age this pet's effects AFTER it acted, so a 2-round debuff modifies
			-- exactly 2 of its attacks
			pet:TickEffects()
		end

		if not self.boss:IsAlive() then
			break
		end
	end

	-- Boss turn — only if the boss is alive and the team isn't wiped.
	if self._running and self.boss:IsAlive() and self:_anyPetAlive() then
		-- a trap (Gorilla's Ground Slam) can stun the boss out of its attack this turn;
		-- its effects still tick (so a bleed keeps chipping while it's stunned).
		local stunned = self.boss:RunTraps()
		if stunned then
			ReplicatedStorage.RemoteEvents.Notifier:FireClient(self.player, {
				notification = "The boss is stunned!",
			})
		else
			self.boss:Attack(self)
		end
		self.boss:TickEffects()
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

-- Options an ability passes to a session primitive. All optional: damage comes
-- from `multiplier * attacker melee` unless `damage` overrides it.
export type AttackOptions = {
	multiplier: number?,
	damage: number?,
	animation: string?,
	text: string?,
	-- floated on the target instead of the number (for a non-damaging move)
	fadeText: string?,
	isSpecial: boolean?,
	-- how long the round loop pauses on this attack (seconds)
	duration: number?,
}

--[=[
	Fires a single "perform your attack" turn: the target mitigates with its own
	private defense, the hit is registered as pending, and the client is told to
	animate `attacker`'s gesture and confirm. Does NOT write health — that happens in
	`ConfirmHit` once the client reports the swing landed. Does not pace; the public
	primitives below own the `task.wait`.
]=]
function FightSessionHandler:_fire(attacker: PetBase.PetBase, target: PetBase.PetBase, opts: AttackOptions)
	local rawDamage = opts.damage or attacker:Outgoing(opts.multiplier or 0)
	local finalDamage = target:Apply(rawDamage) -- process the damage
	local token = self:_pend(target, finalDamage, opts.fadeText)

	CombatTurn:FireClient(self.player, {
		band = attacker.band,
		attackId = opts.isSpecial and "specialAttack" or "basicAttack",
		animation = opts.animation or DEFAULT_ANIMATION,
		isSpecial = opts.isSpecial or false,
		text = (attacker.petName or attacker.id) .. " " .. (opts.text or ""),
		damage = finalDamage,
		token = token,
	} :: NpcFighterTypes.CombatTurnData)
end

--[=[
	Single-target attack used by ability callbacks: fire the hit, then consume the
	attack's `duration` so the round paces correctly.
]=]
function FightSessionHandler:Strike(attacker: PetBase.PetBase, target: PetBase.PetBase, opts: AttackOptions)
	self:_fire(attacker, target, opts)
	task.wait(opts.duration or DEFAULT_DURATION)
end

--[=[
	AOE attack used by ability callbacks: fire one hit per target (each confirmed
	independently) then a single `duration` wait for the whole sweep. All turns carry
	the attacker's band, so the attacker animates once per target on the client.
]=]
function FightSessionHandler:StrikeAll(attacker: PetBase.PetBase, targets: { PetBase.PetBase }, opts: AttackOptions)
	for _, target in ipairs(targets) do
		self:_fire(attacker, target, opts)
	end
	task.wait(opts.duration or DEFAULT_DURATION)
end

--[=[
	A no-damage gesture used by buff/utility abilities: animate the caster and banner
	its `text`, with no TextFade (the buff's icon is the `Health` attribute set by
	`AddEffect`). Token 0 means there is no pending hit, so the client's confirm reply
	is a harmless no-op.
]=]
function FightSessionHandler:Announce(attacker: PetBase.PetBase, opts: AttackOptions)
	CombatTurn:FireClient(self.player, {
		band = attacker.band,
		attackId = "specialAttack",
		animation = opts.animation or DEFAULT_ANIMATION,
		isSpecial = true,
		text = (attacker.petName or attacker.id) .. " " .. (opts.text or ""),
		damage = 0,
		token = 0,
	} :: NpcFighterTypes.CombatTurnData)
	task.wait(opts.duration or DEFAULT_DURATION)
end

-- Registers a pending hit and returns its token. The session owns the token
-- counter (trivially unique) and routes the confirmed hit back to its target.
function FightSessionHandler:_pend(target: PetBase.PetBase, damage: number, fadeText: string?): number
	self._hitSeq += 1
	local token = self._hitSeq
	self._pendingHits[token] = {
		target = target,
		damage = damage,
		fadeText = fadeText,
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

	pending.target:TakeDamage(pending.damage, position, pending.fadeText)
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

-- Every living pet, in band order. The boss's AOE abilities (debuff-all /
-- damage-all) hit this whole set.
function FightSessionHandler:_allAlivePets(): { PetBase.PetBase }
	local alive = {}
	for _, pet in ipairs(self.pets) do
		if pet:IsAlive() then
			table.insert(alive, pet)
		end
	end
	return alive
end

-- The living pet with the least Health — the boss's single-target ability picks
-- the weakest to finish off. Returns nil if the team is wiped.
function FightSessionHandler:_lowestHealthPet(): PetBase.PetBase?
	local weakest: PetBase.PetBase? = nil
	for _, pet in ipairs(self.pets) do
		if pet:IsAlive() then
			if not weakest or pet.health.Value < weakest.health.Value then
				weakest = pet
			end
		end
	end
	return weakest
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
