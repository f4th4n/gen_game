defmodule GenGame.Game.ServerAuthoritative do
  @moduledoc """
  This is a behaviour that you can implement in `lib/gen_game_mod/mod.ex`. Every functions in this module will be called when there are particular event in `GenGame`.
  """

  alias GenGameMod.Mod

  @type socket() :: Phoenix.Socket.t()
  @type shared_opt() :: {:key_iterations, pos_integer()}
  @type error_reason() :: atom()

  @doc """
  RPC is custom action. Payload from user will be passed as-is. The function can either return a map that will be forwarded to the user or return error with reason.
  """
  @callback init() :: :ok
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

  @spec dispatch_event(atom(), keyword()) :: term()
  def dispatch_event(:rpc, payload), do: Mod.rpc(payload)

  def dispatch_event(event, args) do
    is_exist = Mod.module_info(:exports) |> Keyword.get(event)

    if is_exist != nil do
      apply(Mod, event, [args])
    end
  end
end
