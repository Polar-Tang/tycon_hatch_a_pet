local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)

local NPCBase = {}
NPCBase.__index = NPCBase
NPCBase.ClassName = "StateMachine"

function NPCBase.new(char: Model, serviceBag)
	local self = setmetatable({}, NPCBase)

	self.char = char
	self.state = nil
	self._initialized = false
	self._players = {}
	self.serviceBag = serviceBag
	self.maid = Maid.new()

	-- Dead controller will destroy the model and that will clean all this class instance and their state machine as well
	local sub = self.char.AncestryChanged:Connect(function(_, newParent)
		if newParent == nil then
			self:Destroy()
		end
	end)
	self.maid:GiveTask(sub)

	return self
end

function NPCBase.StartCombat(self: NpcFighterTypes.NPCBase, enemy: Model, enemy_hrp: BasePart, enemy_health: IntValue)
	if not self.state then
		print("Binder is not initialized")
		return
	end
	self.state:ChangeData("enemy", enemy)
	self.state:ChangeData("enemy_hrp", enemy_hrp)
	self.state:ChangeData("enemy_health", enemy_health)

	self.state:ChangeState("Combat")
end

function NPCBase:Destroy()
	self.maid:DoCleaning()
	if self.state then
		self.state:Destroy()
	end
end
return NPCBase
