import Config

config :gen_game_app,
  topologies: [
    gossip: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        secret: System.get_env("RELEASE_COOKIE", "gen_game")
      ]
    ]
  ],
  ecto_repos: [GenGameApp.Repo],
  type: :app
