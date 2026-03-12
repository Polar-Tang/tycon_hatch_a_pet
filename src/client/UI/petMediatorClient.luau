local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatControllerClient =
	require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatControllerClient)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local Constants = require(ReplicatedStorage.utils.Constants)
local BossRemoteEvent = ReplicatedStorage.RemoteEvents.BossRemoteEvent

-- SCOPE VARIABLE
local ourFightSession = {} :: NpcFighterTypes.FightInfo
-- Create a boss basses in a template, tag it to initialize, using a scope variable for FightSession
BossRemoteEvent.OnClientEvent:Connect(function(fightSessionData: NpcFighterTypes.FightInfo)
	CombatControllerClient.createInstances(fightSessionData)
	ourFightSession = fightSessionData
end)

local BinderProvider = _G.ServiceBag:GetService(_G.BinderProvider)
local combatFighter = BinderProvider:Get(Constants.combatBet)

-- The instance are created in BossRemoteEvent client event and tagged
combatFighter:GetClassAddedSignal():Connect(function(machine_binder)
	local player = Players.LocalPlayer
	if not next(ourFightSession) or not ourFightSession.player_boss then
		print("not boss remote recived")
		return
	end
	machine_binder:Init(player, ourFightSession.player_boss)
end)

local PetFollower = BinderProvider:Get(Constants.PetFollower)

PetFollower:GetClassAddedSignal():Connect(function(machine_binder)
	local player = Players.LocalPlayer
	if not next(ourFightSession) or not ourFightSession.player_pet then
		print("not boss remote recived")
		return
	end
	machine_binder:Init(player, ourFightSession.player_pet)
end)
