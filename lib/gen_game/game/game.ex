defmodule GenGame.Game.Game do
  @derive Jason.Encoder
  defstruct players: [], state: %{}, status: :open

  @type t :: %__MODULE__{}
end
