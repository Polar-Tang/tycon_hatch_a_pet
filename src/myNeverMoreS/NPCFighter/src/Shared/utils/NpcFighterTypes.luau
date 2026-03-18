local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)
local StateMachine = require(ReplicatedStorage.StateMachine)

export type enemyData = {
	HRP: BasePart,
	Model: Model,
}

export type combatInstanceData = {
	petId: string,
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
}

export type NPCBase = {
	new: (char: Model, serviceBag: any) -> NPCFighterClient,
	StartCombat: (self: NPCFighterClient) -> (),
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
	Init: (self: NPCFighterClient, player: Player, initData: FightInfo) -> (),
	StartCombat: (self: NPCFighterClient) -> (),
	Destroy: (self: NPCFighterClient) -> (),
} & NPCBase

export type healthBarState = "Destroy" | "Init" | "Update"
export type healthBarId = "PlayerBoss" | "PlayerPet"

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
	pet: Model,
	maid: Maid.Maid,
	hrp: BasePart,
	player: Player,
	player_character: Model,
	animationHandler: any,
}

export type FightInfo = {
	player_pet: petStats,
	player_boss: petStats,
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
	GetGoal: (self: TargetController) -> Vector3?,
	CalculatePath: (self: TargetController, goal: Vector3) -> Promise.Promise<Path>,
	_getGoalPos: (self: TargetController) -> Vector3,
} & controllerdataInint

export type MovementController = {
	new: (data: controllerdataInint, serviceBag: any, player: Player) -> MovementController,
	MoveTo: (self: MovementController, Path) -> (),
	_getAtt: (self: MovementController) -> Attachment,
	ForgotPath: (self: MovementController) -> (),
	Stop: (self: MovementController) -> (),
	_lookTo: (self: MovementController, targetPosition: Vector3) -> Promise.Promise<>,
	_moveToWaypoint: (self: MovementController, targetPosition: Vector3, onComplete: () -> ()) -> (),
	getAnimHandler: (self: MovementController) -> any,
	_rotate: (self: MovementController, timer: number) -> CFrame,
	_isRotated: (self: MovementController) -> boolean,
	_jumpToWaypoint: (self: MovementController, targetPosition: Vector3, onComplete: () -> ()) -> (),
	startCFrame: CFrame,
	goalRotation: CFrame,
	_playerLastPos: Vector3,
	_currentMovePromise: Promise.Promise<>?,
	_movementSessionId: number,
	velocity: number,
	isMoving: boolean,
	speed: number,

	moveConn: RBXScriptConnection?,
	moveConnsMaid: Maid.Maid,
	elapsed: number,
	t: number,

	_moveConn: RBXScriptConnection?,
} & controllerdataInint

-- pet only rotates to look at the enemy, play attacks animation, attacks and die
export type bossStateCtx = {
	maid: Maid.Maid,
	pet: Model,
	Health: IntValue,

	timer: number,
	lastTriggerTime: number,

	DeadController: DeadController,
}

export type petStateCtx = {
	maid: Maid.Maid,
	pet: Model,
	--- ON combat --
	enemy: Model,
	enemy_hrp: BasePart,

	timer: number,
	lastTriggerTime: number,

	DeadController: DeadController,
	TargetController: TargetController,
	MovementController: MovementController,
}

return {}
