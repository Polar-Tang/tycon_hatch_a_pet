local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)
local StateMachine = require(ReplicatedStorage.StateMachine)

export type enemyData = {
	HRP: BasePart,
	Model: Model,
}

export type combatInstanceData = {
	-- ordered team the client wants to fight with. Currently the facade only
	-- selects one pet, so this is an array of one, but the wire format is ready
	-- for a multi-select UI. `petId` is kept for back-compat.
	petIds: { string }?,
	petId: string?,
	bossName: string,
}

export type combatInstanceDataInitialization = {
	petId: string,
	bossName: string,
}

export type petStats = {
	healthVal: number,
	meleeVal: number,
	petId: string,
	-- petName drives template/animation lookups; band addresses this fighter's
	-- health value inside the session folder ("PlayerPet1".."PlayerPet3" / "PlayerBoss")
	petName: string?,
	band: healthBarId?,
}

export type NPCBase = {
	new: (char: Model, serviceBag: any) -> NPCFighterClient,
	StartCombat: (self: NPCFighterClient, enemy: Model, enemy_hrp: BasePart, enemy_health: IntValue) -> (),
	Destroy: (self: NPCFighterClient) -> (),

	state: StateMachine.RobloxStateMachine?,

	char: Model,
	_initialized: boolean,
	_players: {},
	serviceBag: any,
	maid: Maid.Maid,
}

export type NPCFighterClient = {

	combat_connection: RBXScriptConnection,

	new: (char: Model, serviceBag: any) -> NPCFighterClient,
	Init: (self: NPCFighterClient, player: Player, initData: FightInfo, expectedPetCount: number) -> (),
	StartCombat: (self: NPCFighterClient) -> (),
	Destroy: (self: NPCFighterClient) -> (),
} & NPCBase

export type healthBarState = "Destroy" | "Init" | "Update"
export type healthBarId = "PlayerBoss" | "PlayerPet1" | "PlayerPet2" | "PlayerPet3"

export type HealthNetData = {
	type: healthBarState,
	petId: healthBarId,
	model: Model,
	percent: number,
	level: number,
	health: number,
}

export type controllerdataInint = {
	healthVal: number,
	meleeVal: number,
	petId: string,
	-- which health value in the session folder this fighter renders ("PlayerPet1".. / "PlayerBoss")
	band: healthBarId?,
	pet: Model,
	maid: Maid.Maid,
	hrp: BasePart,
	player: Player,
	player_character: Model,
	animationHandler: any,
	Humanoid: Humanoid,
}

export type FightInfo = {
	-- ordered team of up to 3 pets; index aligns with the "PlayerPetN" bands
	player_pets: { petStats },
	player_boss: petStats,
}

-- Server -> client "perform your attack" payload. The matching fighter (by band)
-- plays the animation/text and confirms the hit with the token.
export type CombatTurnData = {
	band: healthBarId,
	attackId: string,
	animation: string,
	isSpecial: boolean,
	text: string?,
	damage: number,
	token: number,
}

export type bossCombatConData = {
	enemy: Model,
	enemy_hrp: BasePart,
	enemy_health: IntValue,
	-- which pet reported arrival; the boss keys the team by band so it can wait
	-- for the whole team to be arranged before starting the fight
	band: healthBarId,
}

--|| Controllers
export type DeadController = {
	new: (data: controllerdataInint, serviceBag: any, player: Player) -> DeadController,
	CreateWhirpol: (DeadController) -> (),
	DestroyNPC: (self: DeadController) -> (),
} & controllerdataInint

export type TargetController = {
	_player_hrp: BasePart,
	_lastGoalPos: Vector3,

	modelHeight: number,

	new: (data: controllerdataInint, serviceBag: any, player: Player) -> TargetController,
	GetTo: (self: TargetController, BasePart, distance: number?) -> Vector3,
	GetGoal: (self: TargetController) -> Vector3?,
	CalculatePath: (self: TargetController, goal: Vector3) -> Promise.Promise<Path>,
	_getGoalPos: (self: TargetController) -> Vector3,
} & controllerdataInint

export type MovementController = {
	new: (data: controllerdataInint, serviceBag: any, player: Player) -> MovementController,
	MoveTo: (self: MovementController, Path) -> Promise.Promise<()>,
	ForgotPath: (self: MovementController) -> (),
	Stop: (self: MovementController) -> (),
	_moveToWaypoint: (self: MovementController, targetPosition: Vector3, onComplete: (boolean) -> ()) -> (),
	_jumpToWaypoint: (self: MovementController, targetPosition: Vector3, onComplete: (boolean) -> ()) -> (),
	getAnimHandler: (self: MovementController) -> any,
	LookTo: (self: MovementController, to: Vector3) -> (),
	Destroy: (self: MovementController) -> (),

	_currentMovePromise: Promise.Promise<>?,
	isMoving: boolean,
	speed: number,
	_maid: Maid.Maid,
	humanoid: Humanoid,
	maid_waypoints: Maid.Maid,
} & controllerdataInint

-- pet only rotates to look at the enemy, play attacks animation, attacks and die
export type bossStateCtx = {
	maid: Maid.Maid,
	pet: Model,
	Health: IntValue,
	hrp: BasePart,
	timer: number,
	lastTriggerTime: number,
	player: Player,
	enemy_health: IntValue,
	enemy: Model,
	enemy_hrp: BasePart,

	DeadController: DeadController,
} & controllerdataInint

export type petStateCtx = {
	maid: Maid.Maid,
	pet: Model,
	--- ON combat --
	enemy: Model,
	enemy_hrp: BasePart,
	enemy_health: IntValue,

	timer: number,
	lastTriggerTime: number,

	DeadController: DeadController,
	TargetController: TargetController,
	MovementController: MovementController,
} & controllerdataInint
return {}
