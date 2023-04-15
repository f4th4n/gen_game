import { BehaviorSubject } from 'rxjs'

const playerModel = {
	currentPlayer: new BehaviorSubject({
		/*
    token: '',
		id: '-',
		name: '-',
	*/
	}),
	players: new BehaviorSubject({}),
	/*
		 * players: {
				id: int,
				nick: string,
				pos_x: float,
				pos_y: float,
				inventories: [
					{
						id: int,
						// TODO
					}
				]
			},
		*/
	presences: new BehaviorSubject([]),
	/*
	 * presences: {
			'player:$int': {
				metas: [
					{
						nick: string,
						phx_ref: string,
						id: int,
					},
				],
			},
		},
	*/

	// methods
	setPositions: (eventState) => {
		const players = [...playerModel.players._value]
		const ctxPlayer = players.find((v) => v.id == eventState.player_token)
		if (ctxPlayer) {
		}
	},
}

export { playerModel }
