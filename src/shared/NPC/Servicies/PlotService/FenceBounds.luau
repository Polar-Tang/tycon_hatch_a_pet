export type FenceBoundsService = {
	GetAvailablePlot: (self: FenceBoundsService) -> Model?,
	AssignPlot: (self: FenceBoundsService, plot: Model, player: Player) -> (),
	MarkOffline: (self: FenceBoundsService, plot: Model) -> (),
	_resetPlot: (self: FenceBoundsService, plot: Model) -> (),
	ClampToBounds: (self: FenceBoundsService, plot: BasePart, position: Vector3) -> Vector3,
	IsPositionInsideFenceBounds: (plot: BasePart, position: Vector3) -> boolean,
	GetRandPosition: (self: FenceBoundsService, plot: Model, YOffset: number?) -> Vector3,
	GetPlotByUserId: (Id: string) -> BasePart?,
	GetSpawnPlot: (player: Player) -> BasePart?,
}

return {}
