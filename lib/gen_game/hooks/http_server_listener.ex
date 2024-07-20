defmodule GenGame.Hooks.HttpServerListener do
  defstruct server_url: nil, hook_actions: []

  @moduledoc false
  use GenServer

  require Logger

  alias GenGame.Hooks.HttpServerListener
  alias GenGame.Hooks.HttpRequest

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ignore, name: __MODULE__)
  def hook_actions(), do: GenServer.call(__MODULE__, :hook_actions)
  def server_url(), do: GenServer.call(__MODULE__, :server_url)
  def get_state(), do: GenServer.call(__MODULE__, :get_state)

  @impl true
  def init(_args) do
    {:ok, %HttpServerListener{}, {:continue, :find_server}}
  end

  @impl true
  def handle_continue(:find_server, %HttpServerListener{} = state) do
    updated_state =
      case find_server() do
        nil ->
          state

        hook_actions ->
          updated_state =
            state
            |> Map.put(:server_url, HttpRequest.server_url_config())
            |> Map.put(:hook_actions, hook_actions)

          updated_state
      end

    {:noreply, updated_state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:server_url, _from, %HttpServerListener{server_url: server_url} = state) do
    reply =
      if is_nil(server_url) do
        {:error, :no_server}
      else
        {:ok, server_url}
      end

    {:reply, reply, state}
  end

  def handle_call(:hook_actions, _from, %HttpServerListener{hook_actions: hook_actions} = state) do
    {:reply, {:ok, hook_actions}, state}
  end

  defp find_server() do
    invalid_res =
      "[hooks] response is invalid. To fix, see: #{GenGame.Documentation.path("/docs/features/users")}"

    case HttpRequest.get_request() |> Req.get() do
      {:ok, %{status: 200, body: %{"hooks" => [_h | _t] = hook_actions}}} ->
        Logger.info("[hooks] enable HTTP hooks, actions: #{Enum.join(hook_actions, ", ")}")

        hook_actions

      {:ok, %{status: 200, body: _}} ->
        Logger.error(invalid_res)
        nil

      {:ok, _} ->
        Logger.error(invalid_res)
        nil

      {:error, _error} ->
        Logger.error("[hooks] can't reach HTTP server for GenGame hooks, skipping")
        nil
    end
  end

  # TODO implement health check
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

  # defp get_hook_actions_config() do
  # end
end
