--[[
	This is the npc fighter which only lives in the client and its suposed to live during a fight session and quickly die
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCBase = require(ReplicatedStorage.Nevermore.Custom.NPCBase.src.Client.NPCBase)
local CombatControllerClient =
	require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatControllerClient)
local healthBarListener = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.healthBarListener)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local StateMachine = require(ReplicatedStorage.StateMachine)

local BossCombatCon = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.BossCombatCon

local StatesFolder = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.Machine.States
local NPCFighterClient = setmetatable({}, NPCBase)
NPCFighterClient.__index = NPCFighterClient
NPCFighterClient.ClassName = "NPCFighterClient"

function NPCFighterClient.new(char: Model, serviceBag)
	local self = setmetatable(NPCBase.new(char, serviceBag), NPCFighterClient)

	return self
end

function NPCFighterClient.Init(
	self: NpcFighterTypes.NPCFighterClient,
	player,
	initData: NpcFighterTypes.petStats,
	expectedPetCount: number
)
	-- the state machine is like the npc's brain

	local state = StateMachine.new(
		"Idle",
		StateMachine:LoadDirectory(StatesFolder),
		CombatControllerClient.setBossCtx(self.char, self.serviceBag, player, self.maid, initData)
	)
	self.state = state

	-- Each pet fires BossCombatCon once it reaches its fight slot. Register the
	-- arrivals by band (so a pet reporting twice doesn't double-count) and only
	-- start the fight once the WHOLE team is arranged.
	local arrivedBands: { [string]: boolean } = {}
	local arrivedCount = 0
	local expected = expectedPetCount or 1

	-- A single life connection
	self.combat_connection = BossCombatCon.Event:Connect(function(data: NpcFighterTypes.bossCombatConData)
		if data.band and not arrivedBands[data.band] then
			arrivedBands[data.band] = true
			arrivedCount += 1
		end

		-- wait until every pet has reached its slot
		if arrivedCount < expected then
			return
		end

		-- Notify the server the combat has started (kicks off the round loop)
		ReplicatedStorage.RemoteEvents.NPCFighter:FireServer(player, self.char)
		self:StartCombat(data.enemy, data.enemy_hrp, data.enemy_health)
		self.combat_connection:Disconnect()
	end)
	-- if the pet destroyed and the connection doesn't trigger it will clean anyway
	self.maid:GiveTask(self.combat_connection)

	healthBarListener(player, self.char, "PlayerBoss")

	self._initialized = true

	return self
end

return NPCFighterClient
