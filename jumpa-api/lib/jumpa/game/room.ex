defmodule Jumpa.Game.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :region, :string
    field :token, :string
    has_one :player, Jumpa.Game.Player

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:region, :token])
    |> validate_required([:region, :token])
    |> unique_constraint(:token)
  end
end
