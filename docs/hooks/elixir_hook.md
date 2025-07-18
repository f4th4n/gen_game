---
sidebar_position: 2
---

# Using Elixir

## Extend GenGame Using Elixir

Tutorial to implement server authoritative in GenGame using Elixir.

Almost all actions in GenGame like RPC, create match, etc can be modified with hook. This method is the most recommended one because it is slighty faster as they use direct erlang RPC call instead of async like other methods.

## Example

Let's see simple example how to put our own custom codes into GenGame. We need 2 bash terminal to do this. First one is for GenGame instance, the second one is for our own hook. Please setup your machine first, see Getting Started -> Build Yourself for more detail, then go back here after you finish setup.

Open terminal #1

```bash
. .env && iex --sname gen_game --cookie g3ng4m3 -S mix
```

The bash command is basically loading .env, then spawn erlang node with short name and some cookie, we need to setup this because we'll connect this node with another node later.

Open terminal #2

```bash
cd examples/elixir_hook_example
iex --sname elixir_hook_example --cookie g3ng4m3 -S mix
```

The bash command will spawn erlang node with short name and some cookie. Because the cookie is same with first node, they will connect automatically via Gossip protocol.

That's it! This sample hook will receive some actions from GenGame based on configuration, see `examples/elixir_hook_example/config/config.exs`. For example if a client call an RPC, it will passed to `elixir_hook_example` node, and then they will call `QuickArcade.CommandHandler/1`.

Your hook run on the second node, you can modify your hook code as much as you like.

## Configuration

Put this on your `config/config.exs`

```elixir
config :gen_game,
  mode: :hook,
  hook_actions: [
    rpc: {YourApp.CommandHandler, :rpc},
    before_create_match: {YourApp.CommandHandler, :before_create_match},
    after_create_match: {YourApp.CommandHandler, :after_create_match}
  ]
```

Then you provide a module and function based on your configuration, in this case you need to provide `YourApp.CommandHandler.rpc/1`, `YourApp.CommandHandler.before_create_match/1` and `YourApp.CommandHandler.after_create_match/1`.
