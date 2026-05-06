local function clearAllParticles(effect)
	local function emitAllParticles(parent)
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("ParticleEmitter") then
				child:Clear()
			elseif child:IsA("Attachment") or child:IsA("Model") then
				emitAllParticles(child)
			end
		end
	end
	emitAllParticles(effect)
end

type emitParticlesData = {
	effect: Instance,
	destroy: boolean?,
	particlesToEmit: number?,
	Lifetime : NumberRange?,
}
local function emitParticles(data: emitParticlesData)
	local destroy = data.destroy
	local effect = data.effect
	local particlesToEmit = data.particlesToEmit or 1
	if destroy then
		return clearAllParticles(effect)
	end
	local function emitAllParticles(parent)
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("ParticleEmitter") then
				child.Lifetime = data.Lifetime or NumberRange.new(0.1, 0.3)
				child:Emit(particlesToEmit)
			elseif child:IsA("Attachment") or child:IsA("Model") then
				emitAllParticles(child)
			end
		end
	end
	emitAllParticles(effect)
end

return emitParticles
