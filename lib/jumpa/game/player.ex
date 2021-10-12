defmodule Jumpa.Game.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :nick, :string
    field :room_id, :integer
    field :pos_x, :float
    field :pos_y, :float
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:nick, :room_id, :token])
    |> validate_required([:nick, :room_id, :token])
  end

  # ------
  def get_room_id_by_player(%Jumpa.Game.Player{} = player) do
    player.room_id
  end

  def get_room_id_by_player(_), do: nil
end
