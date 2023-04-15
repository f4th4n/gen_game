import { playerModel } from './models/player-model'
import { request } from './request/request'
import { plainWeb } from './plain-web'
import { unity } from './unity'
import config from './config.json'

const initializeState = {
  waitForUnity: () => {
    if (!window.isInsideUnity) return Promise.resolve()

    return new Promise((resolve, reject) => {
      const pointer = setInterval(() => {
        if (window.unityInstance) {
          clearInterval(pointer)
          resolve()
          return
        }
      }, 50)
    })
  },
  setState: async () => {
    const setPlayer = async () => {
      const getQueryParam = (paramName) => {
        const urlSearchParams = new URLSearchParams(window.location.search)
        const params = Object.fromEntries(urlSearchParams.entries())
        if (!params[paramName]) {
          throw new Error(`Unknown ${paramName}`)
        }

        return params[paramName]
      }

      const playerToken = getQueryParam('player_token')
      const roomToken = getQueryParam('room_token')
      // TODO make roomToken dynamic
      const resPlayer = await request.get(`/players/auth/${playerToken}/${roomToken}`)
      const player = resPlayer.data
      if (!player) throw new Error('Player not found')

      playerModel.currentPlayer.next(player)
    }
    await setPlayer()
  },
  renderState: async () => {
    if (window.isInsideUnity) {
      const currentPlayer = playerModel.currentPlayer._value
      unity.player.start(currentPlayer)
    } else {
      plainWeb.renderPlayer.start()
    }
  },
}

export { initializeState }
