import config from '../config.json'
import { Socket } from 'phoenix'
import { levelChannel } from './level-channel'

const channelModule = {
  start: () => {
    const socket = new Socket(config.wsGameEndpoint, { params: { token: config.roomToken } }) // TODO change token to be dynamic
    socket.connect()

    levelChannel.init(socket)

    return socket
  },
}

// -------------------------------------------------------------------------------- EXPOSE
const socket = channelModule
export { socket }
