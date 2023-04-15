defmodule Jumpa.Game.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :nick, :string
    field :pos_x, :float
    field :pos_y, :float
    field :token, :string
    belongs_to :room, Jumpa.Game.Room

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:nick, :room_id, :token, :pos_x, :pos_y])
    |> validate_required([:nick, :room_id, :token, :pos_x, :pos_y])
  end
end
