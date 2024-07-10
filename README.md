<img src=".github/logo.png?raw=true" width="180">

[![Hex.pm](https://img.shields.io/hexpm/v/gen_game.svg)](https://hex.pm/packages/gen_game) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/gen_game)

# GenGame

GenGame is realtime and distributed game server, runs on Erlang VM.

## Features

- **Users** - Register/login new users via device ID.
- **Relay Multiplayer** - Sending a message or event in the match.
- **Server Authoritative** - Run custom logic using Elixir, Rust and JavaScript.
- **Matchmaker** - Let players finding fair match with expressive query.

## Getting Started

There are 2 ways to start GenGame, using docker or build yourself.

### Using Docker

```bash
docker compose up
```

Test by visiting http://localhost:4000/, if you see `{"status":"ok","app":"gen_game"}` then it works

### Build Yourself

Requirements

1. Elixir
2. Erlang
3. Postgres

Steps

1. Copy .env.example to .env
2. Update .env, fill DATABASE_URL
3. Run command below:

```bash
source .env
iex -S mix phx.server
```

Test by visiting http://localhost:4000/, if you see `{"status":"ok","app":"gen_game"}` then it works

## Deployment

See [this docs](https://hexdocs.pm/phoenix/deployment.html) to deploy. GenGame is built on top of Phoenix, so deployment method is basically the same.

## Extend GenGame With Plugin

## Server Authoritative

Server authoritative means server doing some calculation before sending it to the client. For example, your game need to spawn an enemy or calculating damage based on player's armor, then you use server authoritative method to achieve this.

GenGame can run server authoritative codes using plugins. There are multiple ways to do this.

1. Using Elixir, [see this](/docs/plugin_elixir.md) for the detail
2. Using WebSocket, [see this](/docs/plugin_javascript.md) for the detail

## Client Libraries

# 1. Unity

Visit [gen_game_unity](https://github.com/f4th4n/gen_game_unity) to connect GenGame from Unity.
