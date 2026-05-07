export type EggColor = "red" | "green" | "blue" | "white" | "purple" | "orange"

export type EggData = {
	color: EggColor,
	time: number,
	model: Model?,
	player: Player,
	plot: BasePart,
}


local module = {}


module.expectedItemNameByColor = {
	white = "White Egg",
	red = "Red Egg",
	green = "Green Egg",
	blue = "Blue Egg",
	purple = "Purple Egg",
	orange = "Orange Egg",
}

function module.isEggColor(value: string): boolean
	return module.expectedItemNameByColor[value]
end
module.EggsNames = {
	"White Egg",
	"Red Egg",
	"Green Egg",
	"Blue Egg",
	"Purple Egg",
	"Orange Egg",
}

return module
