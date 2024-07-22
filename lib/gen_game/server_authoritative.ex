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

  @spec dispatch_event(atom(), map()) :: {:ok, term()} | {:error, term()}
  def dispatch_event(event, payload) do
    case find_receiver() do
      {:ok, {:erlang_rpc, node}} -> dispatch_to_erlang_rpc(event, payload, node)
      {:ok, {:http_server, _server_url}} -> dispatch_to_http(event, payload)
      _ -> skip(event, payload)
    end
  end

  defp dispatch_to_erlang_rpc(event, payload, node) do
    with {:ok, hook_actions} <- NodeListener.hook_actions(),
         {m, f} <- Keyword.get(hook_actions, event) do
      rpc_res = :rpc.call(node, m, f, [payload])
      {:ok, rpc_res}
    else
      {:error, :no_hook_actions} -> skip(event, payload)
      nil -> skip(event, payload)
    end
  end

  defp dispatch_to_http(event, event_payload) do
    with {:ok, hook_actions} <- HttpServerListener.hook_actions(),
         :exist <- check_hook_actions(hook_actions, event),
         {:ok, response_message} <- HttpRequest.dispatch_to_server(event, event_payload) do
      {:ok, response_message}
    else
      :skip -> skip(event, event_payload)
    end
  end

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

  defp skip(:rpc, _payload), do: {:error, "no receiver, skip"}
  defp skip(_, payload), do: {:ok, payload}
end
