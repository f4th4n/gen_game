defmodule GenGame.Game.Game do
  @derive Jason.Encoder
  defstruct players: [], public_state: %{}, private_state: %{}, status: :open

  @type t :: %__MODULE__{}
end
