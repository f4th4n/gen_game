defmodule GenGame.Account.Account do
  use Ecto.Schema

  import Ecto.Changeset

  @fields [
    :username,
    :display_name,
    :avatar_url,
    :lang,
    :timezone,
    :metadata,
    :email,
    :wallet
  ]

  @derive {Jason.Encoder, only: @fields}
  schema "accounts" do
    field :username, :string
    field :display_name, :string
    field :avatar_url, :string
    field :lang, :string
    field :timezone, :string
    field :metadata, :string
    field :email, :string
    field :wallet, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, @fields)
    |> validate_required([:username])
    |> validate_username()
    |> unique_constraint(:username)
  end

  def validate_username(cs) do
    username = get_field(cs, :username) || ""

    if String.match?(username, ~r/^[a-zA-Z0-9_]+$/) do
      cs
    else
      add_error(cs, :username, "Username only alphanumeric and _")
    end
  end
end
