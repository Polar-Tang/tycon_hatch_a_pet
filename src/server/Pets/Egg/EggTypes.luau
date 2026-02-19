export type EggColor = "red" | "green" | "blue" | "white"

export type EggData = {
	color: EggColor,
	time: number,
	model: Model?,
	player: Player,
	plot: BasePart,
}

local VALID_EGG_COLORS: { [string]: true } = {
	red = true,
	green = true,
	blue = true,
	white = true,
}

local module = {}
function module.isEggColor(value: string): boolean
	return VALID_EGG_COLORS[value] == true
end

return module
