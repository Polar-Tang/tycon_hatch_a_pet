local scaleModel = require(game:GetService("ReplicatedStorage"):WaitForChild("Helpers"):WaitForChild("ScaleModel"))
return function(data, resized)
	if resized then
		local npc = data.npc
		-- Store this once when spawning NPCs:
		for _, part in ipairs(npc:GetDescendants()) do
			if part:IsA("BasePart") then
				local baseSize = part:GetAttribute("BaseSize")
				if baseSize then
					part.Size = baseSize
				end
			end
		end
	end
	local ownState = require(data.State)
	local maxH = data.health
	data.humanoid.Health = maxH
	data.humanoid.MaxHealth = maxH
	ownState:ChangeState("Idle")
end
