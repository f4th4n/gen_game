import Config

config :gen_game_world,
  topologies: [
    gossip: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        secret: System.get_env("RELEASE_COOKIE", "gen_game")
      ]
    ]
  ],
  enable_game_consumer: {:system, "ENABLE_GAME_CONSUMER", false}

config :gen_game_world,
  type: :world

config :logger, :console, level: :info
