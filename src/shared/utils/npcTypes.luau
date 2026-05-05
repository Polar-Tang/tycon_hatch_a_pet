export type npcMap = {
	id: string,
	name: string,
	model: Model,
}

export type nameToAction = {
	image: string,
	greetings: (selfParent: Model) -> (),
	imageSize: UDim2,
	promptTrigger: (Player, Model) -> (),
	updatePrompt: () -> (),
	finishPrompt: () -> (),
	default: boolean?,
	isOpen: () -> boolean,
}

return {}
