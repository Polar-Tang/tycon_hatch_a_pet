local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local FightSessionHandler = require(script.Parent.FightSessionHandler)

-- Local types
type FightSessionBinder = {
	_sessions: { [number]: any },
	CreateSession: (self: FightSessionBinder, player: Player, data: NpcFighterTypes.combatInstanceData) -> any?,
	GetSession: (self: FightSessionBinder, player: Player) -> any?,
	DestroySession: (self: FightSessionBinder, player: Player) -> (),
}

local CombatController = {}

local _sessions = {}

-- Set by the owner (petMediator) to return a player to their plot when their fight
-- resolves. Kept here so FightSessionHandler stays decoupled from the teleport code.
local _finishCallback: ((player: Player) -> ())? = nil

function CombatController.setFinishCallback(callback: (player: Player) -> ())
	_finishCallback = callback
end

function CombatController.initFightSession(player: Player, data: NpcFighterTypes.FightInfo)
	--[[
	local instanceName = tostring(player.UserId)
	if combatInstanceRegistryFolder:FindFirstChild(instanceName) then
		print("player can be in a single instance at a single time")
		return nil
	end
	local newFolder = Instance.new("Folder", combatInstanceRegistryFolder)
	newFolder.Name = player.UserId
	return newFolder
	]]
	_sessions[player.UserId]:Init(player, data)
end

function CombatController.GetSession(player: Player)
	return _sessions[player.UserId]
end

-- Starts the turn-based round loop for the player's session. Fired once combat
-- actually begins (a fighter binder reports it via the NPCFighter remote).
-- Idempotent at the handler level.
function CombatController.startRounds(player: Player)
	local session = _sessions[player.UserId]
	if not session then
		return
	end
	session:StartRounds()
end

-- Applies a client-confirmed hit (server-authoritative damage was stored when
-- the turn was cast).
function CombatController.confirmHit(player: Player, token: number, position: Vector3?)
	local session = _sessions[player.UserId]
	if not session or typeof(token) ~= "number" then
		return
	end
	session:ConfirmHit(token, position)
end

function CombatController.DestroySession(player: Player)
	local handler = _sessions[player.UserId]
	if not handler then
		return
	end
	if handler then
		handler:Destroy()
		_sessions[player.UserId] = nil
	end
end

-- Legacy methods that map to the handler
function CombatController.getPlayerSessionFolder(player: Player)
	local session = CombatController.GetSession(player)
	return session and session._folderSession or nil
end

function CombatController.getHealth(player: Player, nameInstance: NpcFighterTypes.healthBarId)
	local session = CombatController.GetSession(player)
	return session and session:GetHealth(nameInstance) or nil
end

function CombatController.destroyFightSession(player: Player)
	CombatController.DestroySession(player)
end

-- Keep createAFightSession for compatibility or remove if not needed
function CombatController.createAFightSession(player: Player, data: NpcFighterTypes.combatInstanceData): Folder?
	local handler = FightSessionHandler.new(player)
	print("handler ", handler)
	if handler then
		_sessions[player.UserId] = handler
		-- when the fight resolves on its own, hand the player back to their plot
		handler:SetOnFinish(function()
			if _finishCallback then
				_finishCallback(player)
			end
		end)
	end
	return handler
	
end

-- initFightSession is now in the handler

return CombatController
