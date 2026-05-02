local sharedTypes = {
	item = {
		id = "",
		itemName = "",
		image = "",
		price = 0,
		timestamp = 0,
	},
}

export type item = {
	id: string,
	itemName: string,
	image: string,
	price: number,
	timestamp: number,
}

export type HealthbarComponentData = {
	type: "Destroy" | "Init" | "Update",
	model: Model,
	percent: number,
	petLevel: number,
	health: number,
	petId: string | number, -- depends on your system
	componentName: "HealthBar",
	level: number,
}

export type billBoardContract = {
	componentName: string,
	model: Model | BasePart,
	duration: number,
}

return sharedTypes
