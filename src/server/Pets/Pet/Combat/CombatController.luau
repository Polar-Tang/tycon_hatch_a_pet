local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local combatInstanceRegistryFolder = ReplicatedStorage.Pets.Fights
local FightSessionHandler = require(script.Parent.FightSessionHandler)

-- Local types
type FightSessionBinder = {
	_sessions: { [number]: any },
	new: () -> FightSessionBinder,
	CreateSession: (self: FightSessionBinder, player: Player, data: NpcFighterTypes.combatInstanceData) -> any?,
	GetSession: (self: FightSessionBinder, player: Player) -> any?,
	DestroySession: (self: FightSessionBinder, player: Player) -> (),
}

local CombatController = {}
CombatController.__index = CombatController

function CombatController.new()
	return setmetatable({
		_sessions = {},
	}, CombatController)
end

function CombatController:CreateSession(player: Player, data: NpcFighterTypes.FightInfo)
	-- Note: data is combatInstanceData, but handler needs FightInfo. Assuming FightInfo is passed separately or adjusted.
	-- For now, assuming the data is FightInfo, as per original initFightSession.
	-- Wait, original createAFightSession takes combatInstanceData, but doesn't use it.
	-- So, perhaps CreateSession takes FightInfo.
	-- The user said createAFightSession is for creating the newHandler, so perhaps CreateSession takes the data for init.
	-- To match, let's assume CreateSession takes FightInfo, as the handler.new does.
	-- But the type is combatInstanceData, perhaps change.
	-- For simplicity, change the type to FightInfo.
	local handler = FightSessionHandler.new(player, data)
	if handler then
		self._sessions[player.UserId] = handler
	end
	return handler
end

function CombatController:GetSession(player: Player)
	return self._sessions[player.UserId]
end

function CombatController:DestroySession(player: Player)
	local handler = self._sessions[player.UserId]
	if handler then
		handler:Destroy()
		self._sessions[player.UserId] = nil
	end
end

-- Legacy methods that map to the handler
function CombatController.getPlayerSessionFolder(player: Player)
	local session = CombatController:GetSession(player)
	return session and session._folderSession or nil
end

function CombatController.getHealth(player: Player, nameInstance: NpcFighterTypes.healthBarId)
	local session = CombatController:GetSession(player)
	return session and session:GetHealth(nameInstance) or nil
end

function CombatController.destroyFightSession(player: Player)
	CombatController:DestroySession(player)
end

-- Keep createAFightSession for compatibility or remove if not needed
function CombatController.createAFightSession(player: Player, data: NpcFighterTypes.combatInstanceData): Folder?
	local instanceName = tostring(player.UserId)
	if combatInstanceRegistryFolder:FindFirstChild(instanceName) then
		print("player can be in a single instance at a single time")
		return nil
	end
	local newFolder = Instance.new("Folder", combatInstanceRegistryFolder)
	newFolder.Name = player.UserId
	return newFolder
end

-- initFightSession is now in the handler

return CombatController
