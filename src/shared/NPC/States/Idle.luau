local ReplicatedSorage = game:GetService("ReplicatedStorage")
local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local Idle = State.new("Idle")

Idle.Transitions = {
	require(script.Parent.Parent.Transitions.StartPatrol),
	require(ReplicatedSorage.NPC.Transitions.StartEating),
}

-- Helper to sync a single attribute
local function bindAttribute(attributeName, pet_stats, model)
	-- Initial sync
	local value = model:GetAttribute(attributeName)
	if value ~= nil then
		pet_stats[attributeName] = value
	end

	-- Listen for changes
	local connection = model:GetAttributeChangedSignal(attributeName):Connect(function()
		local newValue = model:GetAttribute(attributeName)
		if newValue ~= nil then
			pet_stats[attributeName] = newValue
		end
	end)

	return connection
end

function Idle:OnInit(data)
	local model = data.pet
	local maid = data.maid

	if not data.isOwnerLocal then
		return
	end

	local petId = model.Name
	local registry = _G.pets_registry
	local petEntry = registry[petId]

	if petId == "fd4ed60c-94a9-4965-8776-3dcd094a89c7" then 
		print()
	end

	if not petEntry or not petEntry.petStats then
		warn("Pet registry entry missing for:", petId)
		return
	end

	local pet_stats = petEntry.petStats

	-- Bind all required attributes
	maid:GiveTask(bindAttribute("Melee", pet_stats, model))
	maid:GiveTask(bindAttribute("Health", pet_stats, model))
	maid:GiveTask(bindAttribute("Stamina", pet_stats, model))
end

function Idle:OnEnter(data)
	data.lastIdleTime = data.timer
end

function Idle:OnHeartbeat(data, deltatime)
	data.timer += deltatime
end

return Idle
