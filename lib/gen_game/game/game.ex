defmodule GenGame.Game.Game do
  @moduledoc """
  A game struct

  ## Fields

  * `:players` - list of player
  * `:public_state` - public state that can be changed by client via relay method
  * `:private_state` - private state that can only be changed by authoritative server method, client can't read any of this state
  * `:read_only_state` - read only state that can be read by anyone including client
  """

  @derive Jason.Encoder
  defstruct players: [],
            public_state: %{},
            private_state: %{},
            read_only_state: %{},
            status: :open

  @type t :: %__MODULE__{}
end
