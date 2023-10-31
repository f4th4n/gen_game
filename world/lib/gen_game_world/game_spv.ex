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
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: GenGameWorld.DynamicGameSpv},
      GenGameWorld.GameManager,
      GenGameWorld.GameConsumer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
