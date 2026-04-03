-- Server-wide type declarations for dynamically injected binders.

export type ValueObject = {
	Value: number,
}

export type PlayerBinder<handler> = {
	_players: { [number]: any },
	_handler: handler,
	new: (handler: handler) -> any,
	InitPlayer: (self: PlayerBinder<handler>, player: Player, pets: any) -> (),
	GetHandler: (self: PlayerBinder<handler>, player: Player) -> handler,
	RemovePlayer: (self: PlayerBinder<handler>, player: Player) -> (),
}

return {}
