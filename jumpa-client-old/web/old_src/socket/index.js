import config from '../config.json'
import { Socket } from 'phoenix'
import { levelChannel } from './level-channel'
import { gameChannel } from './game-channel'

const channelModule = {
  start: () => {
    const socket = new Socket(config.wsGameEndpoint, { params: { token: config.roomToken } }) // TODO change token to be dynamic
    socket.connect()

    levelChannel.init(socket)
    gameChannel.init(socket)

    return socket
  },
}

// -------------------------------------------------------------------------------- EXPOSE
const socket = channelModule
export { socket }
