const express = require('express')
const app = express()
const port = 9500

app.use(express.json())

app.get('/', (req, res) => {
  res.json({
    hooks: ['rpc', 'before_create_match'],
  })
})

app.post('/', (req, res) => {
  const { event, payload } = req.body
  console.log('payload', payload)

  if (event === 'rpc') {
    return res.json({
      status: 'ok',
      msg: 'rpc executed',
      your_payload: payload,
    })
  } else if (event === 'before_create_match') {
    return res.json({
      username: payload.username,
      match_id: 'my_game_' + payload.match_id,
    })
  }

  return res.json({ status: 'ok', msg: 'unknown event' })
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
