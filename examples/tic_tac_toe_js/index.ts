import { Socket } from 'phoenix'

const socket: Socket = new Socket('ws://localhost:4000/socket')

let channel = socket.channel('room:lobby', {})
channel
  .join()
  .receive('ok', (resp) => {
    console.log('Joined successfully', resp)
  })
  .receive('error', (resp) => {
    console.error('Unable to join', resp)
  })

channel.on('new:msg', (message) => {
  console.log('Received message:', message)
})
