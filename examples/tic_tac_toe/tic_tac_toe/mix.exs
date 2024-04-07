defmodule TicTacToe.MixProject do
  use Mix.Project

  def project do
    [
      app: :tic_tac_toe,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TicTacToe.Application, []}
    ]
  end

  defp deps do
    [
      {:libcluster, "~> 3.3"}
    ]
  end
end
