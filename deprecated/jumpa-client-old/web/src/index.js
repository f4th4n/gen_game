import { app } from './app'
/*import { socket } from './socket/index'
import { global } from './global'
import { listeners } from './listeners'*/

console.log('app', app)
app.start()
/*  .then(app.setState)
  .then(() => {
    socket.start()
    listeners.start()
    global.start()
  })
  .catch((e) => {
    console.log('e', e)
    //alert(e)
  })
*/
