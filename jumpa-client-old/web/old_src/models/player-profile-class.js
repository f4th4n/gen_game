class PlayerProfile {
	id = null
	name = ''
	color = [0, 0, 0]
	posX = 0
	posY = 0

	constructor(id = null, name = null, color = null, posX = null, posY = null) {
		this.id = id
		this.name = name
		this.color = color
		this.posX = posX
		this.posY = posY
	}
}

export { PlayerProfile }
