defmodule GenGame.Game.ServerAuthoritative do
  @moduledoc """
  This is a behaviour that you can implement in `lib/gen_game_mod/mod.ex`. Every functions in this module will be called when there are particular event in `GenGame`.
  """

  @type socket() :: Phoenix.Socket.t()
  @type shared_opt() :: {:key_iterations, pos_integer()}
  @type error_reason() :: atom()

  @doc """
  RPC is custom action. Payload from client will be passed as map to the function without modification. The function can either return a map or error with reason that will be forwarded to the client as reply.
  """
  @callback rpc(list()) :: {:ok, map()} | {:error, error_reason()}

  # optionals
  @callback before_create_match(username: binary(), match_id: binary(), socket: socket()) ::
              term()
  @callback after_create_match(list()) :: term()
  @callback before_create_session(username: binary(), socket: socket()) :: term()
  @callback after_create_session(token: binary(), socket: socket()) :: term()
  @callback before_create_account(payload: map(), socket: socket()) :: term()
  @callback after_create_account(account: map(), socket: socket()) :: term()

  @optional_callbacks before_create_match: 1,
                      after_create_match: 1,
                      before_create_session: 1,
                      after_create_session: 1,
                      before_create_account: 1,
                      after_create_account: 1

  alias GenGame.Hooks.NodeListener

  def dispatch_event(event, payload) do
    case find_receiver() do
      {:ok, {:erlang_rpc, node}} -> dispatch_to_erlang_rpc(event, payload, node)
      {:ok, {:http_server, _node}} -> dispatch_to_http(event, payload)
      _ -> "no receiver, skip"
    end
  end

  defp dispatch_to_erlang_rpc(event, payload, node) do
    with {:ok, hook_actions} <- NodeListener.hook_actions(),
         {m, f} <- Keyword.get(hook_actions, event) do
      :rpc.call(node, m, f, [payload])
    else
      {:error, :no_hook_actions} -> skip(event, payload)
      nil -> skip(event, payload)
    end
  end

  defp dispatch_to_http(_event, _payload) do
    {:ok, {:http_server, nil}}
  end

  def find_receiver() do
    try_erlang_rpc = fn ->
      case NodeListener.get() do
        {:ok, node} -> {:ok, {:erlang_rpc, node}}
        {:error, :no_node} -> nil
      end
    end

    try_http_server = fn ->
      case {:error, :no_node} do
        {:ok, node} -> {:ok, {:phx_channel, node}}
        {:error, :no_node} -> nil
      end
    end

    try_erlang_rpc.() || try_http_server.() || {:error, :no_receiver}
  end

  defp skip(:before_create_match, payload), do: payload
  defp skip(_, payload), do: payload
end
