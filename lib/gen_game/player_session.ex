defmodule GenGame.PlayerSession do
  use GenServer

  alias Phoenix.Token
  alias GenGameWeb.Endpoint

  @salt "pl4y3r_s3ss10nz"

  # ----------------------------------------------------------------------------------------------- client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @spec create(binary()) :: binary()
  def create(username) do
    # expired at 100 years
    Token.sign(Endpoint, @salt, username, max_age: 86400 * 30 * 12 * 1000)
  end

  @spec verify(binary()) :: {:ok, binary()} | {:error, :expired | :invalid | :missing}
  def verify(token) do
    Token.verify(Endpoint, @salt, token)
  end

  # ----------------------------------------------------------------------------------------------- server

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:create, username}, _from, state) do
    token = Token.sign(Endpoint, @salt, username)
    {:reply, token, state}
  end
end
