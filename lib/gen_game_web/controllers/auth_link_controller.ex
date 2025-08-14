defmodule GenGameWeb.AuthLinkController do
  use GenGameWeb, :controller

  plug Ueberauth

  require Logger

  alias GenGame.Account.Accounts
  alias GenGame.PlayerSession

  @doc """
  OAuth callback handler for account linking
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    Logger.info("[AuthLinkController] OAuth linking callback received: #{auth.provider}")

    # Retrieve linking token from session
    token = get_session(conn, :link_token)

    case token do
      nil ->
        Logger.warning("[AuthLinkController] No linking token found in session")

        conn
        |> put_status(:bad_request)
        |> json(%{
          success: false,
          error: "missing_token",
          message: "Linking session expired or invalid"
        })

      token when is_binary(token) ->
        # Clear the token from session
        conn = delete_session(conn, :link_token)

        handle_account_linking(conn, auth, token)
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failures}} = conn, _params) do
    Logger.error("[AuthLinkController] OAuth linking failure: #{inspect(failures)}")

    # Clear any session data
    conn = delete_session(conn, :link_token)

    conn
    |> put_status(:unauthorized)
    |> json(%{
      success: false,
      error: "oauth_failed",
      message: "OAuth linking authentication failed"
    })
  end

  # Fallback when OAuth is not configured
  def callback(conn, _params) do
    conn
    |> put_status(:not_implemented)
    |> json(%{
      success: false,
      error: "oauth_not_configured",
      message: "OAuth providers are not configured"
    })
  end

  # Handle account linking flow
  defp handle_account_linking(conn, auth, token) do
    case do_account_linking(auth, token) do
      {:ok, account} ->
        Logger.info("[AuthLinkController] OAuth provider linked to account: #{account.username}")

        conn
        |> put_status(:ok)
        |> json(%{
          success: true,
          message: "OAuth provider linked successfully",
          account: account,
          linked_providers: Accounts.list_linked_providers(account)
        })

      {:error, :invalid_token} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          success: false,
          error: "invalid_token",
          message: "Invalid or expired token"
        })

      {:error, :account_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          success: false,
          error: "account_not_found",
          message: "Account not found"
        })

      {:error, :cannot_use_social_login} ->
        conn
        |> put_status(:forbidden)
        |> json(%{
          success: false,
          error: "cannot_use_social_login",
          message: "Account cannot use social login yet"
        })

      {:error, :provider_already_linked} ->
        conn
        |> put_status(:conflict)
        |> json(%{
          success: false,
          error: "provider_already_linked",
          message: "This OAuth provider is already linked to your account"
        })

      {:error, reason} ->
        Logger.error("[AuthLinkController] Account linking failed: #{inspect(reason)}")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          error: "linking_failed",
          message: "Failed to link OAuth provider"
        })
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

          {:error, _changeset} ->
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
end
