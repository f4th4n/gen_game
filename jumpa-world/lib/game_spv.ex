defmodule JumpaWorld.GameSpv do
  @moduledoc """
  Game supervisor
  """

  use Supervisor

  require Logger

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    children = [
      {JumpaWorld.Game, [5]}
    ]

    Logger.info("application started...")
    Supervisor.init(children, strategy: :rest_for_one)
  end
end
