local ReplicatedSorage = game:GetService("ReplicatedStorage")
local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local Idle = State.new("Idle")

Idle.Transitions = {
	require(script.Parent.Parent.Transitions.StartPatrol),
	require(ReplicatedSorage.NPC.Transitions.StartEating),
}

function Idle:OnInit(data)
	local model = data.pet
	local maid = data.maid

	-- TODO [TASK collectonable pets] use real id
	local petId = model.Name
	local registry = _G.pets_registry
	local petEntry = registry[petId]

	if not petEntry or not petEntry.petStats then
		warn("Pet registry entry missing for:", petId)
		return
	end

	local stats = petEntry.petStats

	-- Helper to sync a single attribute
	local function bindAttribute(attributeName)
		-- Initial sync
		local value = model:GetAttribute(attributeName)
		if value ~= nil then
			stats[attributeName] = value
		end

		-- Listen for changes
		local connection = model:GetAttributeChangedSignal(attributeName):Connect(function()
			local newValue = model:GetAttribute(attributeName)
			if newValue ~= nil then
				stats[attributeName] = newValue
			end
		end)

		maid:GiveTask(connection)
	end

	-- Bind all required attributes
	bindAttribute("Melee")
	bindAttribute("Health")
	bindAttribute("Stamina")
end

function Idle:OnEnter(data)
	data.lastIdleTime = data.timer
end

function Idle:OnHeartbeat(data, deltatime)
	data.timer += deltatime
end

return Idle
