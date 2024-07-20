defmodule GenGame.ServerAuthoritative do
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
  @callback before_create_match(map()) :: term()
  @callback after_create_match(map()) :: term()
  @callback before_create_session(map()) :: term()
  @callback after_create_session(map()) :: term()
  @callback before_create_account(map()) :: term()
  @callback after_create_account(map()) :: term()

  @optional_callbacks before_create_match: 1,
                      after_create_match: 1,
                      before_create_session: 1,
                      after_create_session: 1,
                      before_create_account: 1,
                      after_create_account: 1

  alias GenGame.Hooks.NodeListener
  alias GenGame.Hooks.HttpServerListener
  alias GenGame.Hooks.HttpRequest

  @spec dispatch_event(atom(), map()) :: any()
  def dispatch_event(event, payload) do
    case find_receiver() do
      {:ok, {:erlang_rpc, node}} -> dispatch_to_erlang_rpc(event, payload, node)
      {:ok, {:http_server, _server_url}} -> dispatch_to_http(event, payload)
      _ -> {:error, "no receiver, skip"}
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

  defp dispatch_to_http(event, event_payload) do
    with {:ok, hook_actions} <- HttpServerListener.hook_actions(),
         :exist <- check_hook_actions(hook_actions, event),
         request_body <- request_body(event, event_payload),
         {:ok, res} <- HttpRequest.dispatch_to_server(event, request_body) do
      {:ok, res}
    else
      :skip -> skip(event, event_payload)
    end
  end

  defp request_body(:rpc, %{payload: payload}), do: payload

  defp request_body(:before_create_match, %{username: username, match_id: match_id}),
    do: %{username: username, match_id: match_id}

  defp request_body(:after_create_match, %{username: username, match_id: match_id}),
    do: %{username: username, match_id: match_id}

  defp request_body(:before_create_session, %{username: username}), do: %{username: username}
  defp request_body(:after_create_session, %{token: token}), do: %{token: token}
  defp request_body(:before_create_account, %{payload: payload}), do: payload
  defp request_body(:after_create_account, %{account: account}), do: account

  def find_receiver() do
    try_erlang_rpc = fn ->
      case NodeListener.get() do
        {:ok, node} -> {:ok, {:erlang_rpc, node}}
        {:error, :no_node} -> nil
      end
    end

    try_http_server = fn ->
      case GenGame.Hooks.HttpServerListener.server_url() do
        {:ok, server_url} -> {:ok, {:http_server, server_url}}
        {:error, :no_server} -> nil
      end
    end

    try_erlang_rpc.() || try_http_server.() || {:error, :no_receiver}
  end

  defp check_hook_actions(hook_actions, event) do
    event_str = Atom.to_string(event)
    if event_str in hook_actions, do: :exist, else: :skip
  end

  defp skip(_, payload), do: payload
end
