defmodule GenGameWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :gen_game

  @session_options [
    store: :cookie,
    key: "_gen_game_key",
    signing_salt: "6er+ttC2",
    same_site: "Lax"
  ]

  socket "/game", GenGameWeb.GameSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :gen_game,
    gzip: false,
    only: GenGameWeb.static_paths()

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :gen_game
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug GenGameWeb.Router
end
