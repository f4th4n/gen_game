defmodule GenGameWorld.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_game_world,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
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
      {:rename_project, "~> 0.1.0", only: :dev}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
