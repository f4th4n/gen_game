# Jumpa Repo

Jumpa is distributed generic game server, written in Elixir.

Features:

- [x] player movement
- [x] game room
- [x] authentication & authorization
- [ ] regions
- [ ] NIF

Details:

It is monorepo, consist of 4 projects: `api`, `app`, `world` and `frontend`.

1. api

`api` is elixir application used for interface with the frontend (web, mobile, game client) and used as router. Almost everything will be passed to either `app` or `world`.

2. app

`app` is elixir application used for persisting player data, payment, etc. You can also put business actions here.

3. world

`world` is used for game logic like player movement, fall damage handler, enemy spawner, level, etc. All data is in-memory to maintain performance.

### To start all services

```
docker compose up -d
```

### To connect running node (via attach):

#### api

```
./jumpa api
```

#### app

```
./jumpa app
```

#### world

```
./jumpa world
```

## Kafka UI

localhost:8080
