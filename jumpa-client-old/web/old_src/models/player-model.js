import { BehaviorSubject } from 'rxjs'

/*
playerModel = {
	currentPlayer: {
		token: '',
		id: '-',
		name: '-',
	},
	players: {
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
	presences: {
		'player:$int': {
			metas: [
				{
					nick: string,
					phx_ref: string,
					id: int,
				},
			],
		},
	}
}
*/
const playerModel = {
	currentPlayer: new BehaviorSubject({}),
	players: new BehaviorSubject({}),
	presences: new BehaviorSubject([]),

	// methods
	setPositions: (eventState) => {
		const players = [...playerModel.players._value]
		const ctxPlayer = players.find((v) => v.id == eventState.player_token)
		if (ctxPlayer) {
		}
	},
}

export { playerModel }
