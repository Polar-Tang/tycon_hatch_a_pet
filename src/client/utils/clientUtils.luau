local module = {}

module.checkModelRegister = function(petId)
    -- Changes to ID this
	local petInfo = _G["pets_registry"][petId]
	if not petInfo.model then 
		petInfo.model = workspace:FindFirstChild(petId)
	end
end

return module
