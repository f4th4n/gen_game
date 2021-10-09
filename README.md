# Jumpa

## Up

```
# for dev:
elixir --sname jumpa -S mix phx.server

# for dev:
PORT=4001 MIX_ENV=jumpa elixir --sname prod -S mix phx.server

# connect to those session
# iex --remsh jumpa --sname dev
# iex --remsh jumpa --sname dev2

```

## Channels

#### Connect to server
```
$ wscat -c 'ws://localhost:4000/game/websocket?vsn=2.0.0'

> ["1","1","ping","phx_join",{}]
> [null,null,"ping","send_ping",{"from_node":"server@127.0.0.2"}]

Example join a level channel
["1","1","level","phx_join",{"player_id": 1, "room_id": 1}]
> [null,null,"level","request_ping",{"from_node":"server@127.0.0.2"}]
```

### Server broadcast msg to client
> JumpaWeb.Endpoint.broadcast("ping", "try", %{yo: "adalah"})
