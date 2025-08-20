defmodule GenGameWeb.AuthController do
  use GenGameWeb, :controller

  plug GenGameWeb.Plugs.OAuthLinkMiddleware when action == :request
  plug Ueberauth

  require Logger

  alias GenGame.Account.Accounts
  alias GenGame.PlayerSession

  @doc """
  OAuth callback handler for social login and account linking
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    Logger.debug("[AuthController] OAuth callback received: #{auth.provider}")

    # Get token from session (set by middleware)
    token =
      case get_session(conn, :oauth_token) do
        nil -> nil
        token when is_binary(token) -> token
      end

    link_mode =
      case get_session(conn, :oauth_link_mode) do
        nil -> false
        mode when is_boolean(mode) -> mode
      end

    # Clean up session data regardless of success/failure
    conn = cleanup_oauth_session(conn)

    # Check if this is a linking request based on session data
    case {link_mode, token} do
      {true, token} when is_binary(token) ->
        Logger.debug("[AuthController] Handling OAuth account linking")
        handle_account_linking(conn, auth, token)

      {false, token} when is_binary(token) ->
        Logger.debug("[AuthController] Handling OAuth social login")
        handle_social_login(conn, auth, token)

      _ ->
        Logger.warning("[AuthController] No valid token found in session")

        response_data = %{
          success: false,
          error: "missing_token",
          msg: "No valid token found for OAuth flow"
        }

        conn
        |> put_status(:bad_request)
        |> send_oauth_response(response_data, nil)
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failures}} = conn, _params) do
    Logger.error("[AuthController] OAuth failure: #{inspect(failures)}")

    # Get token from session
    token = get_session(conn, :oauth_token)

    response_data = %{
      success: false,
      error: "oauth_failed",
      msg: "Social login authentication failed"
    }

    conn
    |> cleanup_oauth_session()
    |> put_status(:unauthorized)
    |> send_oauth_response(response_data, token)
  end

  # Fallback when OAuth is not configured
  def callback(conn, _params) do
    # Get token from session
    token = get_session(conn, :oauth_token)

    response_data = %{
      success: false,
      error: "oauth_not_configured",
      msg: "OAuth providers are not configured"
    }

    conn
    |> cleanup_oauth_session()
    |> put_status(:not_implemented)
    |> send_oauth_response(response_data, token)
  end

  # Handle social login flow
  defp handle_social_login(conn, auth, token) do
    case do_social_login(auth) do
      {:ok, new_token, account} ->
        Logger.debug("[AuthController] Social login successful for username: #{account.username}")

        response_data = %{
          success: true,
          token: new_token,
          account: account,
          msg: "Social login successful"
        }
        Logger.debug("[AuthController] going to send new token after social login: #{new_token}")

        send_oauth_response(conn, response_data, token)

      {:error, :account_not_found} ->
        Logger.warning("[AuthController] Account not found for social login")

        response_data = %{
          success: false,
          error: "account_not_found",
          msg: "You must create an account first before using social login"
        }

        conn
        |> put_status(:not_found)
        |> send_oauth_response(response_data, token)
    end
  end

  # Handle account linking flow
  defp handle_account_linking(conn, auth, token) do
    case do_account_linking(auth, token) do
      {:ok, account} ->
        Logger.info("[AuthController] OAuth provider linked to account: #{account.username}")

        response_data = %{
          success: true,
          msg: "OAuth provider linked successfully",
          account: account,
          linked_providers: Accounts.list_linked_providers(account)
        }

        send_oauth_response(conn, response_data, token)

      {:error, :invalid_token} ->
        response_data = %{
          success: false,
          error: "invalid_token",
          msg: "Invalid or expired token"
        }

        conn
        |> put_status(:unauthorized)
        |> send_oauth_response(response_data, token)

      {:error, :account_not_found} ->
        response_data = %{
          success: false,
          error: "account_not_found",
          msg: "Account not found"
        }

        conn
        |> put_status(:not_found)
        |> send_oauth_response(response_data, token)

      {:error, :cannot_use_social_login} ->
        response_data = %{
          success: false,
          error: "cannot_use_social_login",
          msg: "Account cannot use social login yet"
        }

        conn
        |> put_status(:forbidden)
        |> send_oauth_response(response_data, token)

      {:error, :provider_already_linked} ->
        response_data = %{
          success: false,
          error: "provider_already_linked",
          msg: "This OAuth provider is already linked to your account"
        }

        conn
        |> put_status(:conflict)
        |> send_oauth_response(response_data, token)

      {:error, :provider_uid_already_exists} ->
        response_data = %{
          success: false,
          error: "provider_uid_already_exists",
          msg: "This Google account is already linked to another GenGame account"
        }

        conn
        |> put_status(:conflict)
        |> send_oauth_response(response_data, token)

      {:error, reason} ->
        Logger.error("[AuthController] Account linking failed: #{inspect(reason)}")

        response_data = %{
          success: false,
          error: "linking_failed",
          msg: "Failed to link OAuth provider"
        }

        conn
        |> put_status(:unprocessable_entity)
        |> send_oauth_response(response_data, token)
    end
  end

  # Core social login logic
  defp do_social_login(auth) do
    provider = to_string(auth.provider)
    uid = auth.uid

    # Check if account already linked to this OAuth provider
    case Accounts.get_by_oauth_provider(provider, uid) do
      %{username: username} = account ->
        # Account already linked - generate new token (multiple sessions support)
        new_token = PlayerSession.create(username)
        Logger.debug("[AuthController] Social login successful for username: #{username}, created new token: #{new_token}")
        {:ok, new_token, account}

      nil ->
        {:error, :account_not_found}
    end
  end

  # Core account linking logic
  defp do_account_linking(auth, token) do
    with {:ok, username} <- PlayerSession.verify(token),
         account when not is_nil(account) <- Accounts.get_by_username(username) do
      if Accounts.can_use_social_login?(account) do
        case Accounts.link_oauth_provider(account, auth) do
          {:ok, updated_account} ->
            {:ok, updated_account}

          {:error, :provider_uid_already_exists} ->
            {:error, :provider_uid_already_exists}

          {:error, :provider_already_linked} ->
            {:error, :provider_already_linked}

          {:error, changeset} ->
            Logger.error("[AuthController] Account linking failed: #{inspect(changeset)}")
            {:error, :linking_failed}
        end
      else
        {:error, :cannot_use_social_login}
      end
    else
      {:error, _} -> {:error, :invalid_token}
      nil -> {:error, :account_not_found}
    end
  end

  # Clean up OAuth session data
  defp cleanup_oauth_session(conn) do
    conn
    |> delete_session(:oauth_link_mode)
    |> delete_session(:oauth_token)
  end

  # Send OAuth response - Broadcast via PubSub and return simple HTML
  defp send_oauth_response(conn, data, token) do
    Logger.debug("[AuthController] send_oauth_response called with token: #{inspect(token)}")

    # If token is provided, broadcast the result via PubSub
    if token && is_binary(token) do
      topic = "oauth_result:#{token}"
      Logger.debug("[AuthController] Broadcasting OAuth result to topic: #{topic}")
      Logger.debug("[AuthController] Broadcasting data: #{inspect(data)}")

      case Phoenix.PubSub.broadcast(GenGame.PubSub, topic, {:oauth_result, data}) do
        :ok ->
          Logger.debug("[AuthController] PubSub broadcast successful")
        {:error, reason} ->
          Logger.error("[AuthController] PubSub broadcast failed: #{inspect(reason)}")
      end
    else
      Logger.warning("[AuthController] token is nil or not binary, skipping PubSub broadcast")
    end

    # Return HTML response with appropriate styling
    html_response(conn, data)
  end

  # Generate HTML response with appropriate success/error message
  defp html_response(conn, data) do
    {title, message, status_class} = case data do
      %{success: true, msg: msg} ->
        {"OAuth Success", msg, "success"}

      %{success: false, msg: msg} ->
        {"OAuth Failed", msg, "error"}
    end

    # Add styling based on status
    background_color = case status_class do
      "success" -> "#d4edda"
      "error" -> "#f8d7da"
      "warning" -> "#fff3cd"
      _ -> "#d1ecf1"
    end

    text_color = case status_class do
      "success" -> "#155724"
      "error" -> "#721c24"
      "warning" -> "#856404"
      _ -> "#0c5460"
    end

    html = """
    <!DOCTYPE html>
    <html>
    <head>
      <title>#{title}</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 0;
          padding: 40px;
          background-color: #f5f5f5;
        }
        .container {
          max-width: 500px;
          margin: 0 auto;
          background-color: #{background_color};
          color: #{text_color};
          padding: 30px;
          border-radius: 8px;
          border: 1px solid rgba(0,0,0,0.1);
          text-align: center;
        }
        h2 { margin-top: 0; }
        .close-instruction {
          margin-top: 20px;
          font-size: 14px;
          opacity: 0.8;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h2>#{title}</h2>
        <p>#{message}</p>
        <p class="close-instruction">You can close this tab.</p>
      </div>
    </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(conn.status || 200, html)
  end
end
