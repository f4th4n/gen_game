import Config

config :gen_game,
  mode: :hook,
  hook_actions: [
    rpc: {QuickArcade.CommandHandler, :rpc},
    before_create_match: {QuickArcade.CommandHandler, :before_create_match},
    matchmaker_soft_expiration: {QuickArcade.CommandHandler, :matchmaker_soft_expiration},
    matchmaker_hard_expiration: {QuickArcade.CommandHandler, :matchmaker_hard_expiration}
  ]
