import config from '../config.json'

const request = {
  get: async (path) => {
    const res = await fetch(config.apiGameEndpoint + path)
    return await res.json()
  },
}

// -------------------------------------------------------------------------------- EXPOSE
export { request }
