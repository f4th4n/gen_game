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

  def dispatch_event(event, payload) do
    with {:ok, node} <- GenGame.PluginNodeListener.get(),
         {:ok, plugin_actions} <- GenGame.PluginNodeListener.plugin_actions(),
         {m, f} <- Keyword.get(plugin_actions, event) do
      :rpc.call(node, m, f, [payload])
    else
      {:error, :no_node} -> skip(event, payload)
      {:error, :no_plugin_actions} -> skip(event, payload)
      nil -> skip(event, payload)
    end
  end

  defp skip(:before_create_match, payload), do: payload
  defp skip(_, payload), do: payload
end
