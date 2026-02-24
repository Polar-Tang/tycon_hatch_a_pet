export type npcMap = {
	id: string,
	name: string,
	model: Model,
}

export type nameToAction = {
	image: string,
	greetings: (selfParent: Model) -> (),
	imageSize: UDim2,
	promptTrigger: () -> (),
	updatePrompt: () -> (),
	finishPrompt: () -> (),
	default: boolean?,
	isOpen: () -> boolean,
}

return {}
