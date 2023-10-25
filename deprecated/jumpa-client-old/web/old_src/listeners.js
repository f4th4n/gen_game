import { presencesListener } from './game/presences-listener'

const listeners = {
	start: () => {
		presencesListener.init()
	},
}

export { listeners }
