local ItemTypes = {}

export type Item = {
	rarity: "common" | "uncommon" | "rare" | "epic",
	buffKind: "XP" | "DMG" | "speed" | "stamina" | "poisonHealth",
	type: "consumable" | "buff",
	name: string,
	buff: number,
}

return ItemTypes
