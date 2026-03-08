local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effects = ReplicatedStorage:WaitForChild("Effects")

return function(data)
	local npc = data.npc
	local bolt: Model
	local petElement = data.petElement

	if bolt then
		bolt = bolt:Clone()
		for k, v in pairs(bolt:GetDescendants()) do
			if v:IsA("WeldConstraint") then
				v:Destroy()
			end
		end
	else
		if petElement == "frost" then
			bolt = Effects:WaitForChild("FrostBolt")
		elseif petElement == "nature" then
			bolt = Effects:WaitForChild("PoisonBolt")
		elseif petElement == "fire" then
			bolt = Effects:WaitForChild("FireBolt")
		else
			bolt = Effects:WaitForChild("PoisonBolt")
		end
	end

	return bolt:Clone()
end
