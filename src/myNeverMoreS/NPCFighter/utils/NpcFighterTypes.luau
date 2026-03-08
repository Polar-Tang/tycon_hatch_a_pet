local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)
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
} & controllerdataInint

export type TargetController = {
	new: (data: controllerdataInint, serviceBag: any, player: Player) -> DeadController,
	Update: (self: TargetController) -> Vector3?,

	_playerLastPos: Vector3,
} & controllerdataInint

export type FollowerController = {
	new: (data: controllerdataInint, serviceBag: any, player: Player) -> DeadController,
	MoveTo: (self: FollowerController, Vector3) -> (),
	_getAtt: (self: FollowerController) -> Attachment,

	_playerLastPos: Vector3,
	_currentMovePromise: Promise.Promise<>,
	velocity: number,
	isMoving: boolean,
	speed: number,

	_moveConn: RBXScriptConnection?,
} & controllerdataInint

export type bossStateCtx = {
	maid: Maid.Maid,
	pet: Model,

	timer: number,
	lastTriggerTime: number,

	DeadController: DeadController,
	TargetController: TargetController,
	FollowerController: FollowerController,
}

return {}
