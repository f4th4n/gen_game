defmodule GenGame.Hooks.HttpRequest do
  require Logger

  # rpc event is special, they skip @http_req_res_keys validation
  @http_req_res_keys %{
    rpc: %{
      request_keys: :rpc,
      response_keys: :rpc
    },
    before_create_match: %{
      request_keys: [:username, :match_id],
      response_keys: [:username, :match_id]
    },
    after_create_match: %{
      request_keys: [:username, :match_id],
      response_keys: nil
    }
  }

  def get_request() do
    Req.new(retry_log_level: false, max_retries: 1, base_url: server_url_config())
  end

  def server_url_config() do
    server_config = Application.get_env(:gen_game, :http_hook)

    "#{Keyword.get(server_config, :scheme)}://#{Keyword.get(server_config, :host)}:#{Keyword.get(server_config, :port)}"
  end

  def dispatch_to_server(event, event_payload) do
    # TODO make async if response body is not used
    get_request()
    |> Req.post(
      json: %{
        event: Atom.to_string(event),
        payload: build_request_body(event, event_payload)
      }
    )
    |> case do
      {:ok, %Req.Response{status: 200, body: res_body}} ->
        {:ok, build_response(event, event_payload, res_body)}

      error ->
        Logger.error("[dispatch_to_server] #{inspect(error)}")
    end
  end

  def build_request_body(:rpc, event_payload), do: Map.get(event_payload, :payload)

  def build_request_body(event, event_payload) do
    %{request_keys: request_keys} = Map.get(@http_req_res_keys, event)
    Map.take(event_payload, request_keys)
  end

  def build_response(event, event_payload, res_body) do
    %{response_keys: response_keys} = Map.get(@http_req_res_keys, event)

    case response_keys do
      :rpc ->
        res_body

      nil ->
        nil

      response_keys ->
        response_keys = Enum.map(response_keys, &Atom.to_string(&1))
        event_payload_keys = event_payload |> Map.keys() |> Enum.map(&Atom.to_string(&1))

        Enum.reduce(response_keys, event_payload, fn response_key, acc ->
          if response_key in event_payload_keys do
            valid_key = String.to_existing_atom(response_key)
            Map.put(acc, valid_key, Map.get(res_body, response_key))
          else
            acc
          end
        end)
    end
  end
end
