defmodule Jumpa.Game.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :region, :string
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:region, :token])
    |> validate_required([:region, :token])
  end
end
