local ReplicatedStorage = game:GetService("ReplicatedStorage")
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local Brio = require(ReplicatedStorage.Nevermore.Quenty.brio.Shared.Brio)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local incomeUtils = require(ReplicatedStorage.utils.incomeUtils)
-- Server-wide type declarations for dynamically injected binders.


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
	Xp: ValueObject.ValueObject<number>,
	CoinsFactor: ValueObject.ValueObject<number>,
	EggRNG: ValueObject.ValueObject<number>,
	EggDurationFactor: ValueObject.ValueObject<number>,
	StorageSlot: ValueObject.ValueObject<number>,
	Haggling: ValueObject.ValueObject<number>,
	KiblyFactor: ValueObject.ValueObject<number>,
	Luck: ValueObject.ValueObject<number>,
	ExtraCoinBoss: ValueObject.ValueObject<number>,
	DoubledCoin: ValueObject.ValueObject<number>,
	_slightlyIncreased: ValueObject.ValueObject<number>,
	pets: {ValueObject.ValueObject<any>},
	boosters: { boosterType: incomeUtils.boosterList },

	-- Injected handlers
	inventory: PlayerInventory,
	bestiaryList: any, -- or specific type if available

	_maid: Maid.Maid,

	new: (self: Income) -> Income,
	Init: (self: Income, serviceBag: any) -> (),
	_setCoinIncome: (self: Income, serviceBag: any) -> (),
	_checkIncreases: (self: Income, input: number) -> number,
	Destroy: (self: Income) -> (),
}

export type PetData = PetTypes.PetData & {
	bonus: (incomes: Income) -> (),
}

export type PetsDataStore = { [string]: PetData }

export type Petsinformation = { [PetTypes.petNames]: PetData }

-- Player Inventory Types
export type InventoryItem = {
	itemId: string,
	-- add other item fields here
	[string]: any,
}

export type PlayerData = {
	-- Core state
	player: Player,
	cash: number,

	lastRegisterTime: number,

	-- Internal runtime state
	_timer: number,
	_last_timer: number,
	_maid: any, -- Maid

	-- ===== Methods =====

	getRegisterTime: (self: PlayerData) -> number,
	setRegisterTime: (self: PlayerData) -> (),

	Init: (self: PlayerData, money_cb: (number) -> () -> number) -> (),
	Destoy: (self: PlayerData) -> (),
}

export type PlayerInventoryInit = {
	player: Player,
	cash: number?,
	items : any
}

export type PlayerInventory = {
	-- Core state
	cash: number,
	lastRegisterTime: number,

	-- Internal runtime state
	_maid: any, -- Maid

	-- Methods
	getRegisterTime: (self: PlayerInventory) -> number,
	setRegisterTime: (self: PlayerInventory) -> (),
	Init: (self: PlayerInventory, money_cb: () -> number) -> (),
	Destroy: (self: PlayerInventory) -> (),
	IncreaseMoney: (self: PlayerInventory, amount: number) -> number,
	DecreaseMoney: (self: PlayerInventory, amount: number) -> number?,
	RemoveItemById: (self: PlayerInventory, itemId: string) -> boolean,
} & PlayerInventoryInit

-- Pet Controller Type
export type PetController = {
	_petId: string,
	_data: PetData,
	ValueObject: Brio.Brio<PetData>,
	new: (petId: string, data: PetData) -> PetController,
	Destroy: (self: PetController) -> (),
	spendPoint: (self: PetController, abillityName: string) -> boolean,
	increaseXP: (self: PetController, newPetProg: number, petModel: Model?) -> PetData?,
	_levelUpPet: (self: PetController) -> (),
	_ensureValidEat: (self: PetController) -> boolean,
	getStats: (self: PetController) -> any, -- PetData.petStats
	getData: (self: PetController) -> PetData,
	getId: (self: PetController) -> string,
}

return {}
