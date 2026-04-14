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

return sharedTypes