defmodule JumpaApi.Game.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :region, :string
    field :token, :string
    field :status, Ecto.Enum, values: [:open, :started, :finished]
    has_one :player, JumpaApi.Game.Player

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
