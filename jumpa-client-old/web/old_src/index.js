import { initializeState } from './initialize-state'
import { socket } from './socket/index'
import { global } from './global'
import { listeners } from './listeners'

initializeState
  .waitForUnity()
  .then(initializeState.setState)
  .then(initializeState.renderState)
  .then(() => {
    socket.start()
    listeners.start()
    global.start()
  })
  .catch((e) => {
    console.log('e', e)
    //alert(e)
  })
