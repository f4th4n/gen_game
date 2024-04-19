[![Hex.pm](https://img.shields.io/hexpm/v/gen_game.svg)](https://hex.pm/packages/gen_game) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/gen_game)

# GenGame

GenGame is realtime and distributed game server, runs on Erlang VM.

# Features

* **Users** - Register/login new users via device ID.
* **Relay Multiplayer** - Sending a message or event in the match.
* **Server Authoritative** - Run custom logic using Elixir, Rust and JavaScript.
* **Matchmaker** - Let players finding fair match with expressive query.

# Getting Started

There are 2 ways to start GenGame, using docker or build yourself.

## Using Docker

```bash
docker compose up
```

Test by visiting http://localhost:4000/, if you see `{"status":"ok","app":"gen_game"}` then it works

## Build Yourself

Requirements

1. Elixir
2. Erlang
3. Postgres

Steps

1. Copy .env.example to .env
2. Update .env, fill DATABASE_URL
3. Run command below:

```bash
. .env
iex -S mix phx.server
```

Test by visiting http://localhost:4000/, if you see `{"status":"ok","app":"gen_game"}` then it works

# Deployment

See [this docs](https://hexdocs.pm/phoenix/deployment.html) to deploy. GenGame is built on top of Phoenix, so deployment method is basically the same.
