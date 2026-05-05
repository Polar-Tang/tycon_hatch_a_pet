export type npcMap = {
	id: string,
	name: string,
	model: Model,
}

export type nameToAction = {
	image: string,
	greetings: (selfParent: Model) -> (),
	imageSize: UDim2,
	promptTrigger: (Player, Model, number?) -> (),
	updatePrompt: () -> (),
	finishPrompt: () -> (),
	default: boolean?,
	isOpen: () -> boolean,
}

return {}
