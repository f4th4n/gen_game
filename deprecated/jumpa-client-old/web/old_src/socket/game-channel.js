import { playerModel } from '../models/player-model'

const gameChannel = {
	channel: null,
	socket: null,
	state: {
		currentPlayer: null,
	},

	init: (socket) => {
		gameChannel.socket = socket
		gameChannel.subscribeState()
	},

	subscribeState: () => {
		playerModel.currentPlayer.subscribe({
			next: (currentPlayer) => {
				gameChannel.state.currentPlayer = currentPlayer
				gameChannel.registerChannel()
			},
		})
	},

	registerChannel() {
		const currentPlayer = gameChannel.state.currentPlayer
		const payload = { player_token: currentPlayer.token }
		const channel = gameChannel.socket.channel('game', payload)
		gameChannel.channel = channel

		channel
			.join()
			.receive('ok', (resp) => {
				console.log('Joined successfully', resp)
			})
			.receive('error', (resp) => {
				console.log('Unable to join', resp)
			})

		gameChannel.addEvents(channel)
	},

	addEvents: (channel) => {},
}

// -------------------------------------------------------------------------------- EXPOSE
export { gameChannel }
