import { playerModel } from '../models/player-model'
import { levelChannel } from '../socket/level-channel'
import config from '../config.json'

const presencesListener = {
  init: (socket) => {
    presencesListener.subscribe()
  },

  subscribe: () => {
    playerModel.presences.subscribe({
      next: (presences) => {
        presencesListener.setAllPlayersData()
      },
    })

    playerModel.players.subscribe({
      next: (players) => {
        presencesListener.setAllPlayersData()
      },
    })
  },

  setAllPlayersData: () => {
    const presences = playerModel.presences._value
    const players = playerModel.players._value

    for (let k in presences) {
      const playerId = presences[k].metas[0].player_id
      const player = players[playerId]

      if (player) continue // no need to resolve

      // TODO check idempotency
      levelChannel.channel.push('get_player_detail', { player_id: playerId, room_token: config.roomToken })
    }
  },
}

export { presencesListener }
