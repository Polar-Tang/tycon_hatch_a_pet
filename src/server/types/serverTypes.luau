local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local incomeUtils = require(ReplicatedStorage.utils.incomeUtils)
-- Server-wide type declarations for dynamically injected binders.

export type ValueObject = {
	Value: number,
}

export type PlayerBinder<handler> = {
	_players: { [number]: any },
	_handler: handler,
	new: (handler: handler) -> any,
	InitPlayer: (self: PlayerBinder<handler>, player: Player, ...any) -> (),
	GetHandler: (self: PlayerBinder<handler>, player: Player) -> handler,
	RemovePlayer: (self: PlayerBinder<handler>, player: Player) -> (),
}

-- Fight Session Types
export type PlayerPetInstance = {
	Health: IntValue,
	Id: StringValue,
}

export type PlayerBossInstance = {
	Health: IntValue,
	Id: StringValue,
}

export type FightSessionHandler = {
	_folderSession: Folder,
	PlayerPet: PlayerPetInstance,
	PlayerBoss: PlayerBossInstance,
	new: (player: Player, data: any) -> FightSessionHandler,
	GetHealth: (self: FightSessionHandler, nameInstance: string) -> IntValue?,
	Destroy: (self: FightSessionHandler) -> (),
}

export type FightSessionBinder = {
	_sessions: { [number]: FightSessionHandler },
	new: () -> FightSessionBinder,
	CreateSession: (self: FightSessionBinder, player: Player, data: any) -> FightSessionHandler?,
	GetSession: (self: FightSessionBinder, player: Player) -> FightSessionHandler?,
	DestroySession: (self: FightSessionBinder, player: Player) -> (),
}

export type Income = {
	Xp: ValueObject,
	CoinsFactor: ValueObject,
	EggRNG: ValueObject,
	EggDurationFactor: ValueObject,
	StorageSlot: ValueObject,
	Haggling: ValueObject,
	KiblyFactor: ValueObject,
	Luck: ValueObject,

	pets: {ValueObject},
	boosters: { boosterType: incomeUtils.boosterList },

	_maid: Maid.Maid,

	new: (self: Income) -> Income,
	Init: (self: Income, serviceBag: any) -> (),
}

export type PetData = PetTypes.PetData & {
	bonus: (incomes: Income) -> (),
}

export type PetsDataStore = { [string]: PetData }

export type Petsinformation = { [PetTypes.petNames]: PetData }

return {}
