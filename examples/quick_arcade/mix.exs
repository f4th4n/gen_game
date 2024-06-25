defmodule QuickArcade.MixProject do
  use Mix.Project

  def project do
    [
      app: :quick_arcade,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {QuickArcade.Application, []}
    ]
  end

  defp deps do
    [
      {:gen_game_plugin, path: "/home/fathan/work/f/gen_game/gen_game_plugin_ex"},
      {:libcluster, "~> 3.3"}
    ]
  end
end
