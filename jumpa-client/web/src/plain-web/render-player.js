import { playerModel } from '../models/player-model'

const renderPlayer = {
  start: () => {
    renderPlayer.subscribe()
  },

  subscribe: () => {
    playerModel.presences.subscribe({
      next: (v) => renderPlayer.render(),
    })
    playerModel.players.subscribe({
      next: (v) => renderPlayer.render(),
    })
  },

  render: () => {
    const order = (presences) => {
      return Object.values(presences).sort((a, b) => a.metas[0].nick.localeCompare(b.metas[0].nick))
    }

    var html = ''
    const presences = order(playerModel.presences._value)
    for (let presence of presences) {
      const player_id = presence.metas[0].player_id
      const player = playerModel.players._value[player_id]

      html += `<li>
        nick: ${player_id}<br />
        ${player ? `position: x ${player.pos_x}, y ${player.pos_y}}` : ''}
        <br /><br />
      </li>`
    }
    window.document.querySelector('#player-list').innerHTML = html
  },
}

export { renderPlayer }
