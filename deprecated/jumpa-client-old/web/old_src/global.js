import { game } from './game/index'
import { levelChannel } from './socket/level-channel'
import { gameChannel } from './socket/game-channel'
import { playerModel } from './models/player-model'
import { request } from './request/request'
import { unity } from './unity'

const global = {
	start: () => {
		window.ff = {
			game,
			channels: {
				levelChannel,
				gameChannel,
			},
			models: {
				playerModel,
			},
			request,
			unity,
		}
	},
}

export { global }
