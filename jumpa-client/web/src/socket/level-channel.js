import { Presence } from 'phoenix'
import { playerModel } from '../models/player-model'
import { position } from '../game/position'

// TODO refactor this to be more readable, probably separate between action and calculation
const levelChannel = {
  channel: null,
  socket: null,
  presences: [],
  state: {
    currentPlayer: null,
  },

  init: (socket) => {
    levelChannel.socket = socket
    levelChannel.subscribe()
  },

  subscribe: () => {
    playerModel.currentPlayer.subscribe({
      next: (currentPlayer) => {
        levelChannel.state.currentPlayer = currentPlayer
        levelChannel.create()
      },
    })
  },

  create: () => {
    const currentPlayer = levelChannel.state.currentPlayer
    const payload = { player_token: currentPlayer.token }
    const roomToken = currentPlayer.room.token
    const channel = levelChannel.socket.channel('level:' + roomToken, payload)
    levelChannel.channel = channel

    channel
      .join()
      .receive('ok', (resp) => {
        console.log('Joined successfully', resp)
      })
      .receive('error', (resp) => {
        console.log('Unable to join', resp)
      })

    levelChannel.addEvents(channel)
  },

  addEvents: (channel) => {
    channel.on('ping', (state) => {
      console.log('there is ping from server', state, +new Date())
    })

    channel.on('presence_state', (state) => {
      const presences = Presence.syncState(playerModel.presences._value, state)
      playerModel.presences.next(presences)
    })

    channel.on('presence_diff', (diff) => {
      const presences = Presence.syncDiff(playerModel.presences._value, diff)
      playerModel.presences.next(presences)
    })

    channel.on('walk_absolute', (state) => {
      position.updatePlayerPos(state)
    })

    channel.on('player_detail', (state) => {
      var players = { ...playerModel.players._value }
      players[state.player_id] = state
      playerModel.players.next(players)

      for (let player of Object.values(players)) {
        position.updatePlayerPos(player)
      }
    })
  },
}

// -------------------------------------------------------------------------------- EXPOSE
export { levelChannel }
