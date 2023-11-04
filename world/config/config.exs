import Config

config :gen_game_world,
  topologies: [
    gossip: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        secret: System.get_env("RELEASE_COOKIE", "gen_game")
      ]
    ]
  ]

config :gen_game_world,
  type: :world

config :logger, :console, level: :info
