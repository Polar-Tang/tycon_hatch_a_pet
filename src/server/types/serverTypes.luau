-- Server-wide type declarations for dynamically injected binders.

export type ValueObject = {
	Value: number,
}

export type PlayerBinder = {
	_players: { [number]: any },
	_handler: any,
	new: (handler: any) -> any,
	InitPlayer: (self: any, player: Player, pets: any) -> (),
	GetHandler: (self: any, player: Player) -> any,
	RemovePlayer: (self: any, player: Player) -> (),
}

return {}
