local module = {}

export type billboardShit = {
	componentName: string,
	model: Model,
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

return module
