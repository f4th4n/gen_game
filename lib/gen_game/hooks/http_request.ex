defmodule GenGame.Hooks.HttpRequest do
  require Logger

  def get_request() do
    Req.new(retry_log_level: false, max_retries: 1, base_url: server_url_config())
  end

  def server_url_config() do
    server_config = Application.get_env(:gen_game, :http_hook)

    "#{Keyword.get(server_config, :scheme)}://#{Keyword.get(server_config, :host)}:#{Keyword.get(server_config, :port)}"
  end

  def dispatch_to_server(event, payload) do
    get_request()
    |> Req.post(
      json: %{
        event: Atom.to_string(event),
        payload: payload
      }
    )
    |> case do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      error ->
        Logger.error("[dispatch_to_server] #{inspect(error)}")
    end
  end
end
