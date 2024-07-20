const express = require('express')
const app = express()
const port = 9500

app.use(express.json())

app.get('/', (req, res) => {
  res.json({
    hooks: ['rpc', 'before_create_game'],
  })
})

app.post('/', (req, res) => {
  res.json({ status: 'ok', msg: 'update tile to bla bla' })

  if (req.body.event === 'rpc') {
    res.json({ status: 'ok', msg: 'rpc executed' })
  } else if (req.body.event === 'before_create_game') {
    res.json({ status: 'ok', msg: 'before_create_game executed' })
  } else {
    res.json({ status: 'ok', msg: 'unknown event' })
  }
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
