defmodule GenGameWeb.Presence do
  use Phoenix.Presence,
    otp_app: :gen_game,
    pubsub_server: GenGame.PubSub
end
