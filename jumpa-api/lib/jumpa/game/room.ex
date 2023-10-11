defmodule JumpaApi.Game.Room do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:region, :token, :status]}

  schema "rooms" do
    field :region, :string
    field :token, :string
    # TODO restrict room by status
    field :status, Ecto.Enum, values: [:open, :started, :finished], default: :open
    has_one :player, JumpaApi.Game.Player

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:region, :token, :status])
    |> validate_required([:region, :token])
    |> unique_constraint(:token)
  end
end
