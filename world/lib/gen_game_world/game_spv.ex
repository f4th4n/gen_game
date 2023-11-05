defmodule GenGameWorld.GameSpv do
  @moduledoc """
  Game supervisor
  """

  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    children =
      [
        {DynamicSupervisor, strategy: :one_for_one, name: GenGameWorld.DynamicGameSpv},
        {DynamicSupervisor, strategy: :one_for_one, name: GenGameWorld.DynamicNodesSpv},
        GenGameWorld.GameManager
      ] ++ game_consumer()

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp game_consumer() do
    enabled? = Confex.get_env(:gen_game_world, :enable_game_consumer)

    if enabled? do
      [GenGameWorld.GameConsumer]
    else
      []
    end
  end
end
