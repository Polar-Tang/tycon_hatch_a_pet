local module = {}

export type itemType = {
	Name: string,
	Amount: number,
}

export type PlayerData = {
	player: Player,
	gold: number,
	inventory: { [string]: itemType },
	leaderstats: Folder?,
	invokedPet: Model?,
	playerBackpack: Backpack?,

	AddItem: (self: PlayerData, newItem: itemType) -> PlayerData?,
	RemoveItem: (self: PlayerData, ItemName: string) -> PlayerData?,
	GetLeaderstats: (self: PlayerData) -> Folder?,
	PlayerMoney: (self: PlayerData) -> IntValue?,
	InvokePet: (self: PlayerData, pet: Model) -> (),
	SaveBackPack: (self: PlayerData, backpack: Backpack) -> (),
}
return module
