defmodule GenGameWorld.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_game_world,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/f4th4n/gen_game/tree/master/world",
      docs: [
        extras: ["README.md", "api_docs.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {GenGameWorld.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.3"},
      {:broadway_kafka, "~> 0.3.0"},
      {:phoenix_pubsub, "~> 2.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:uuid, "~> 1.1"}
    ]
  end

  defp description() do
    "gen_game_world is component of GenGame that handle game server in realtime"
  end

  defp package() do
    [
      name: :gen_game_world,
      maintainers: ["Wildan Fathan"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/f4th4n/gen_game/tree/master/world"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
