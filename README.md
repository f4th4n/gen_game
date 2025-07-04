<img src=".github/logo.png?raw=true" width="180">

[![Hex.pm](https://img.shields.io/hexpm/v/gen_game.svg)](https://hex.pm/packages/gen_game) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/gen_game)

# GenGame

Visit GenGame [Official Site](https://gengame.rhinobytes.id)

GenGame is realtime and distributed game server, runs on Erlang VM.

Whether you're building a social network game, MMORPG, or TCG, GenGame helps you create a robust backend game server, offering clients for popular game platforms. It's also extensible with Elixir/Erlang or any HTTP server.

## Features

- **Users** - Register/login new users.
- **Relay Multiplayer** - Sending a message or event in the match.
- **Server Authoritative** - Execute custom logic using Elixir/Erlang or any programming language via HTTP server.
- **Matchmaker** - Let players finding fair match with expressive query.

## Getting Started

Let's discover **GenGame** in less than 5 minutes.

There are two ways to get GenGame up and running: using Docker or building it from source. We recommend using Docker, as it's easier to manage. Building from source is intended for those who want to develop GenGame further or are interested in understanding how it works under the hood.

### Using Docker (Recommended)

First, create a file `docker-compose.yml`.

```yaml
services:
  gen_game:
    container_name: gen_game
    image: f4th4n/gen_game:latest
    environment:
      DATABASE_URL: ecto://postgres:postgres@postgres/gen_game_prod
    depends_on:
      - postgres
    ports:
      - 4000:4000

  postgres:
    container_name: postgres
    image: postgres:14-alpine
    healthcheck:
      test: "pg_isready -U postgres"
    volumes:
      - postgres:/var/lib/postgresql/data
    environment:
      PSQL_HISTFILE: /root/log/.psql_history
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: gen_game_prod
    ports:
      - 5433:5432

volumes:
  postgres:
```

Then run the command:

```bash
docker compose up
```

Test by visiting http://localhost:4000/, if you see response below then congratulation, it works:

```json
{
  "status": "ok",
  "app": "gen_game"
}
```

### Build Yourself

Requirements

1. Elixir
2. Erlang
3. Postgres

Steps

1. Clone the <u>[repo](https://github.com/f4th4n/gen_game)</u>
2. Copy `.env.example` to `.env`
3. Update `.env`, fill DATABASE_URL
4. Run command below:

```bash
source .env
iex --sname gen_game --cookie g3ng4m3 -S mix phx.server
```

Test by visiting http://localhost:4000/, if you see:

```json
{
  "status": "ok",
  "app": "gen_game"
}
```

then it works.

## Upgrade

To update to the latest version of GenGame:

If you are using Docker, change the tag to the newer version. You can see the full list of tags at [Docker Hub](https://hub.docker.com/r/f4th4n/gen_game).

If you are building it yourself, pull the newer code from [the repository](https://github.com/f4th4n/gen_game) and then rebuild.

## Client Libraries

#### Unity

If you're using Unity or any C# application then you should use [gen_game_unity](https://github.com/f4th4n/gen_game_unity) to connect to GenGame server.

#### JavaScript

If you're using PhaserJS, Cocos2d-x, Construct3, Telegram Game, Facebook Instant Game, or any JavaScript application then you should use [gen_game_js](https://github.com/f4th4n/gen_game_client_js) to connect to GenGame server.

## Extend With Hooks

You can extend GenGame functionality beyond its capability with **hooks**. Hooks let you run your own function in between events, so you can achieve thing like server authoritative actions.

Server authoritative means server doing some calculation before sending it to the client. For example, your game need to spawn an enemy or calculating damage based on player's armor.

There are 2 ways to do this.

1. Using Elixir
2. Using any other programming language

## Documentation

See how to use GenGame in the documentation [here](/docs). Elixir and Erlang developers can find the API documentation [here](https://hexdocs.pm/gen_game).

## Benchmark

Is GenGame really fast? The main strength of GenGame is not raw speed but concurrent connection. They can handle ~20k concurrent connection with 2 CPU 4 GB memory easily. You can read the whole article how we did this [here](https://medium.com/p/c4e68ae2dc4e).

<img src=".github/benchmark.webp?raw=true"  height="250">
