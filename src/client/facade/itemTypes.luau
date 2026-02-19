export type itemData = {
	title: string,
	image: string,
	description: string,
	price: number,
	itemName: string,
	template: Model,
	createPivot: (CFrame, Vector3) -> CFrame,
	cameraRotation: ((CFrame, Vector3) -> CFrame)?,
}

return {}
