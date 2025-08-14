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
        |> put_session(:oauth_link_token, token)

      %{"link_mode" => "true"} ->
        Logger.warning("[OAuthLinkMiddleware] Link mode enabled but no token provided")

        # Link mode without token - return error
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{
          success: false,
          error: "missing_token",
          message: "Token is required when link_mode=true"
        })
        |> halt()

      %{} ->
        # Normal OAuth login flow - no special handling needed
        conn
    end
  end
end
