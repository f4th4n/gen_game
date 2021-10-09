defmodule Jumpa.Game.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :nick, :string
    field :room_id, :string

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:nick, :room_id])
    |> validate_required([:nick, :room_id])
  end
end
