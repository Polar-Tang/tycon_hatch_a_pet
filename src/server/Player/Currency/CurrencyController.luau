local CurrencyController = {}
-- PlayerQuestHandler.lua
CurrencyController.__index = CurrencyController
type PlayerData = {
	player: Player,
	cash: number,
}

function CurrencyController.new(cash): PlayerData
	local self = setmetatable({}, CurrencyController)
	-- self.cash
    return self
end

function CurrencyController:Destroy(cash)
	
	
end


return CurrencyController
