import Config

config :jumpa_app,
  topologies: [
    gossip: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        secret: System.get_env("RELEASE_COOKIE", "jumpa")
      ]
    ]
  ],
  ecto_repos: [JumpaApp.Repo],
  type: :app
