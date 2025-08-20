defmodule GenGameWeb.Plugs.OAuthLinkMiddleware do
  @moduledoc """
  Middleware to handle OAuth linking parameters.
  Sets assigns for link_mode and token to be used in OAuth callback.
  """

  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.params do
      %{"link_mode" => "true", "token" => token} when is_binary(token) ->
        Logger.info("[OAuthLinkMiddleware] Link mode enabled with token")

        # Store linking data in session for the callback
        conn
        |> put_session(:oauth_link_mode, true)
        |> put_session(:oauth_token, token)

      %{"token" => token} when is_binary(token) ->
        Logger.debug("[OAuthLinkMiddleware] OAuth token provided for social login")

        # Store token for social login (no link_mode)
        conn
        |> put_session(:oauth_token, token)

      _ ->
        Logger.warning("[OAuthLinkMiddleware] No token provided for OAuth flow")

        # No token provided - return error since we need it for WebSocket notification
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{
          success: false,
          error: "missing_token",
          msg: "Token is required for OAuth authentication"
        })
        |> halt()
    end
  end
end
