local module = {}

export type petNames = "Fox" | "Hippo" | "Rhino" | "Elephant" | "Panda" | "Lion" | "Cat" | "Dog"

module.allPetNames = { "Fox", "Hippo", "Rhino", "Elephant", "Panda", "Lion", "Cat", "Dog" }

export type petStats = {
	Health: number,
	Melee: number,
	Stamina: number,
}

export type PetData = {
	petProg: number,
	isInvoked: boolean,
	avaiblePoints: number,
	petName: petNames,
	petLvl: number,
	petId: string,
	petStats: petStats,
	rarity: rarity,
	CameraDistanceFactor: number,
}

export type PetsDataStore = { [string]: PetData }

export type Petsinformation = { [petNames]: PetData }

export type petInitFrontend = {
	eat_interval: number,
	eat_duration: number,
	range: number,
	patrol_interval: number,
	patrol_duration: number,
	base: number,
	velocity: number,
	speed: number,
	adorneeOffset: Vector3?,
	YOffset: number?,
	rarity: rarity,
	CameraDistanceFactor: number,
	radPivot: number?,
	ZradPivot: number?,
}

export type petsInitFrontend = { petNames: petInitFrontend }

export type rarity = "common" | "uncommon" | "rare" | "epic" | "legendary"

module.isPetName = function(name: string)
	if not name or typeof(name) ~= "string" then
		warn("name '", name, "' no valid")
		return
	end
end

return module
