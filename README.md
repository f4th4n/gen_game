# GenGame

GenGame is distributed generic game server, written in Elixir.

Features:

- [x] player movement
- [x] game room
- [x] authentication & authorization
- [ ] regions
- [ ] NIF

## Details:

GenGame is monorepo consist of 4 projects: `api`, `app`, `world` and `client`. Every backend applications (api, app, world) can be scaled horizontally. It means that you can scale based on business requirements. For example if the game need to crunch numbers heavily, you should spawn few more `world` nodes in order to distribute work load. The nodes will be automatically connected, thanks to libcluster.

1. api

`api` is used for interfacing with the client (web, mobile, game engine). It is also used as router, almost all actions will be passed to either `app` or `world`.

2. app

`app` is used for business actions. It can be used for persisting player data, economy data, etc.

3. world

`world` is used for game logic like player movement, fall damage handler, enemy spawner, level, etc. All data is in-memory to maintain performance.

4. client

`client` is example of how client communicate with `api`. Currently there are example client for web and [godot engine](https://godotengine.org). You can use any game engine you want as long as it can open WebSocket connection.

![Alt text](docs/big_pict.png?raw=true "Big pict")

# Installation

## Requirements

- Docker

## Start

```
./gen_game start
```

## Connect to running node, attach mode:

```
./gen_game api|app|world

Example:
./gen_game api
```

## API Contract

TODO add API contracts here
