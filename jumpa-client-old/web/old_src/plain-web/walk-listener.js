import { playerModel } from '../models/player-model'

const walkListener = {
  listen: () => {
    $('#walk-left').addEventListener('click', this.walkLeft)
  },

  walkLeft: () => {
    console.log('walk left')
  },
}

export { walkListener }
