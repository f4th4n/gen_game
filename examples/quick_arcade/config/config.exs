import Config

config :gen_game,
  mode: :plugin,
  plugin_actions: [
    rpc: {QuickArcade.CommandHandler, :rpc},
    before_create_match: {QuickArcade.CommandHandler, :before_create_match}
  ]
