defmodule Jumpa.Game.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :nick, :string
    field :room_id, :integer
    field :pos_x, :float
    field :pos_y, :float

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:nick, :room_id, :pos_x, :pos_y])
    |> validate_required([:nick, :room_id, :pos_x, :pos_y])
  end
end
