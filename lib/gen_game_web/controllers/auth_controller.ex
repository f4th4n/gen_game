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
    Logger.info("[AuthController] OAuth callback received: #{auth.provider}")

    token =
      case get_session(conn, :oauth_link_token) do
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
        Logger.info("[AuthController] Handling OAuth account linking")
        handle_account_linking(conn, auth, token)

      _ ->
        Logger.info("[AuthController] Handling OAuth social login")
        handle_social_login(conn, auth)
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failures}} = conn, _params) do
    Logger.error("[AuthController] OAuth failure: #{inspect(failures)}")

    response_data = %{
      success: false,
      error: "oauth_failed",
      message: "Social login authentication failed"
    }

    conn
    |> cleanup_oauth_session()
    |> put_status(:unauthorized)
    |> send_oauth_response(response_data)
  end

  # Fallback when OAuth is not configured
  def callback(conn, _params) do
    response_data = %{
      success: false,
      error: "oauth_not_configured",
      message: "OAuth providers are not configured"
    }

    conn
    |> cleanup_oauth_session()
    |> put_status(:not_implemented)
    |> send_oauth_response(response_data)
  end

  # Handle social login flow
  defp handle_social_login(conn, auth) do
    case do_social_login(auth) do
      {:ok, token, account} ->
        Logger.info("[AuthController] Social login successful for username: #{account.username}")

        response_data = %{
          success: true,
          token: token,
          account: account,
          message: "Social login successful"
        }

        send_oauth_response(conn, response_data)

      {:error, :account_not_found} ->
        Logger.warning("[AuthController] Account not found for social login")

        response_data = %{
          success: false,
          error: "account_not_found",
          message: "You must create an account first before using social login"
        }

        conn
        |> put_status(:not_found)
        |> send_oauth_response(response_data)
    end
  end

  # Handle account linking flow
  defp handle_account_linking(conn, auth, token) do
    case do_account_linking(auth, token) do
      {:ok, account} ->
        Logger.info("[AuthController] OAuth provider linked to account: #{account.username}")

        response_data = %{
          success: true,
          message: "OAuth provider linked successfully",
          account: account,
          linked_providers: Accounts.list_linked_providers(account)
        }

        send_oauth_response(conn, response_data)

      {:error, :invalid_token} ->
        response_data = %{
          success: false,
          error: "invalid_token",
          message: "Invalid or expired token"
        }

        conn
        |> put_status(:unauthorized)
        |> send_oauth_response(response_data)

      {:error, :account_not_found} ->
        response_data = %{
          success: false,
          error: "account_not_found",
          message: "Account not found"
        }

        conn
        |> put_status(:not_found)
        |> send_oauth_response(response_data)

      {:error, :cannot_use_social_login} ->
        response_data = %{
          success: false,
          error: "cannot_use_social_login",
          message: "Account cannot use social login yet"
        }

        conn
        |> put_status(:forbidden)
        |> send_oauth_response(response_data)

      {:error, :provider_already_linked} ->
        response_data = %{
          success: false,
          error: "provider_already_linked",
          message: "This OAuth provider is already linked to your account"
        }

        conn
        |> put_status(:conflict)
        |> send_oauth_response(response_data)

      {:error, reason} ->
        Logger.error("[AuthController] Account linking failed: #{inspect(reason)}")

        response_data = %{
          success: false,
          error: "linking_failed",
          message: "Failed to link OAuth provider"
        }

        conn
        |> put_status(:unprocessable_entity)
        |> send_oauth_response(response_data)
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
        token = PlayerSession.create(username)
        {:ok, token, account}

      nil ->
        # No existing OAuth link found
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
    |> delete_session(:oauth_link_token)
  end

  # Send OAuth response - Always HTML for OAuth endpoints
  defp send_oauth_response(conn, data) do
    # OAuth endpoints should always return HTML with postMessage for popup compatibility
    html_response(conn, data)
  end

  # Generate HTML response with postMessage
  defp html_response(conn, data) do
    json_data = Jason.encode!(data)

    html = """
    <!DOCTYPE html>
    <html>
    <head>
      <title>OAuth Result</title>
    </head>
    <body>
      <script>
        console.log('OAuth callback page loaded with data:', #{json_data});
        try {
          const data = #{json_data};
          console.log('Attempting to send postMessage:', data);

          if (window.opener) {
            console.log('Sending to window.opener');
            window.opener.postMessage(data, '*');
            setTimeout(() => window.close(), 100);
          } else if (window.parent && window.parent !== window) {
            console.log('Sending to window.parent');
            window.parent.postMessage(data, '*');
          } else {
            console.log('No opener or parent, showing result on page');
            document.body.innerHTML = '<h2>' + (data.success ? 'Success!' : 'Error') + '</h2><p>' + data.message + '</p><p><a href="#" onclick="window.close()">Close Window</a></p>';
          }
        } catch (e) {
          console.error('OAuth callback error:', e);
          document.body.innerHTML = '<h2>Error</h2><p>OAuth callback failed: ' + e.message + '</p><p><a href="#" onclick="window.close()">Close Window</a></p>';
        }
      </script>
    </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(conn.status || 200, html)
  end
end
