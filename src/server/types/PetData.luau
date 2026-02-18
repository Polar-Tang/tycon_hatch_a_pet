-- Type definition for pet data
export type PetData = {
	petProg: number,
	isInvoked: boolean,
	avaiblePoints: number,
	petName: string,
	petLvl: number,
	petStats: {
		Health: number,
		Melee: number,
		Stamina: number,
	},
	petId: string,
}

export type InitData = { [string]: PetData }
return {}
