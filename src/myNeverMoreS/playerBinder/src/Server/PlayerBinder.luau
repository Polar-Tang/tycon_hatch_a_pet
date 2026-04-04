local PlayerBinder = {}
PlayerBinder.__index = PlayerBinder

-- DI factory can be a constructor table or function.
function PlayerBinder.new(handler)
	assert(handler ~= nil, "PlayerBinder requires a handler constructor")
	local self = setmetatable({
		_players = {},
		_handler = handler,
	}, PlayerBinder)
	return self
end

function PlayerBinder:InitPlayer(player, ...)
	local handler
	if type(self._handler) == "table" and type(self._handler.new) == "function" then
		handler = self._handler.new(...)
	elseif type(self._handler) == "function" then
		handler = self._handler(...)
	else
		error("PlayerBinder._handler must be a table with .new or a function")
	end

	self._players[player.UserId] = handler
end

function PlayerBinder:GetHandler(player)
	return self._players[player.UserId]
end

function PlayerBinder:RemovePlayer(player)
	self._players[player.UserId] = nil
end

return PlayerBinder
