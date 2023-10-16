import Config

config :jumpa_app,
  topologies: [
    gossip: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        secret: System.get_env("RELEASE_COOKIE", "jumpa")
      ]
    ]
  ]

config :jumpa_app,
  ecto_repos: [JumpaApp.Repo]