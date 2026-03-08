local function calcularOroAvanzado(data): number
	-- Configuración por defecto
	local suerteBaseMin = 10
	local suerteBaseMax = 50
	local factorNivel = 0.1
	local rangoSuerte = 10
	local probabilidadGolpeSuerte = 0.01 -- 1%
	if not data.enemyModel then
		return
	end
	local diferenciaNiveles = data.npc.level.Value - data.enemyModel.Level.Value

	-- Diferencia de niveles

	-- Número aleatorio base
	local numeroSuerte = math.random(1, rangoSuerte)

	-- Verificar golpe de suerte (probabilidad baja de número muy alto)
	if math.random() < probabilidadGolpeSuerte then
		numeroSuerte = math.random(rangoSuerte / 2, rangoSuerte * 10)
		print("¡GOLPE DE SUERTE! Número de suerte: " .. numeroSuerte)
	end

	-- Factor de diferencia de niveles
	local factorDiferencia = 1 + (diferenciaNiveles * factorNivel)

	-- Oro base aleatorio
	local oroBase = math.random(suerteBaseMin, suerteBaseMax)

	-- Cálculo final usando logaritmo para suavizar números muy grandes
	local oroFinal = math.max(1, math.floor(oroBase * factorDiferencia * math.log(numeroSuerte + 1)))

	return oroFinal
end

-- Ejemplos de la versión avanzada
local configEjemplo = {
	suerteBaseMin = 10,
	suerteBaseMax = 100,
	factorNivel = 0.1,
	rangoSuerte = 1000,
	probabilidadGolpeSuerte = 0.01,
}

return calcularOroAvanzado
