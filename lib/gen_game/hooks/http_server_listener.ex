defmodule GenGame.Hooks.HttpServerListener do
  @moduledoc false
  use GenServer

  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{server_node: nil, hook_actions: []}, name: __MODULE__)
  end

  def hook_actions() do
    GenServer.call(__MODULE__, :hook_actions)
  end

  def get() do
    GenServer.call(__MODULE__, :get_node)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @impl true
  def init(_args) do
    {:ok, %{server: nil, hook_actions: []}, {:continue, :find_server}}
  end

  @impl true
  def handle_continue(:find_server, state) do
    new_state =
      case find_server() do
        nil ->
          {:noreply, state}

        _hook_actions ->
          {:noreply, state}
      end

    {:noreply, new_state}
  end

  defp find_server() do
    req = get_request()

    case Req.get(req) do
      {:ok, %{status: 200, body: %{"hooks" => [_h | _t] = hook_actions}}} ->
        IO.inspect({"hook_actions", hook_actions})
        hook_actions

      {:ok, %{status: 200, body: _}} ->
        Logger.warning(
          "[GenGame.Hooks.HttpServerListener] can connect to #{server_url()}, but response structure is invalid"
        )

      {:error, _error} ->
        Logger.warning(
          "[GenGame.Hooks.HttpServerListener] can't reach HTTP server for GenGame hooks, skipping"
        )

        nil
    end
  end

  def get_request() do
    Req.new(retry_log_level: false, max_retries: 1, base_url: server_url())
  end

  # defp health_check(url) do
  #   case Req.head(url) do
  #     {:ok,
  #      %Req.Response{
  #        status: 200
  #      }} ->
  #       :healthy

  #     _ ->
  #       :not_healthy
  #   end
  # end

  defp server_url() do
    server_config = Application.get_env(:gen_game, :hook_http)

    "#{Keyword.get(server_config, :scheme)}://#{Keyword.get(server_config, :host)}:#{Keyword.get(server_config, :port)}"
  end

  # defp get_hook_actions_config() do
  # end
end
