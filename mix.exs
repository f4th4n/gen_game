defmodule GenGame.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_game,
      version: "0.1.2",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {GenGame.Application, []},
      extra_applications: [:logger, :wx, :observer, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    phoenix_deps() ++
      [
        {:telemetry_metrics, "~> 0.6"},
        {:telemetry_poller, "~> 1.0"},
        {:libcluster, "~> 3.3"},
        {:confex, "~> 3.5"},
        {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
        {:req, "~> 0.5.4"}
      ]
  end

  defp phoenix_deps() do
    [
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, "~> 0.17"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.7"}
    ]
  end

  defp description() do
    "GenGame is realtime and distributed game server"
  end

  defp package() do
    [
      name: :gen_game,
      maintainers: ["Wildan Fathan"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/f4th4n/gen_game"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
