defmodule GenGame.PlayerSession do
  use GenServer

  alias Phoenix.Token
  alias GenGameWeb.Endpoint

  @salt "pl4y3r_s3ss10nz"

  # ----------------------------------------------------------------------------------------------- client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @spec generate_token(binary()) :: term()
  def generate_token(username) do
    GenServer.call(__MODULE__, {:generate_token, username})
  end

  # ----------------------------------------------------------------------------------------------- server

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:generate_token, username}, _from, state) do
    token = Token.sign(Endpoint, @salt, username)
    {:reply, token, state}
  end
end
