# GenGameApi

## Scenario

## Channels

#### Connect to server

```
$ wscat -c 'ws://localhost:4000/game/websocket?vsn=2.0.0'

> ["1","1","ping","phx_join",{}]
> [null,null,"ping","send_ping",{"from_node":"server@127.0.0.2"}]

Example join a level channel
> ["1","1","level","phx_join",{"player_token": "abc"}]
> [null,null,"level","request_ping",{"from_node":"server@127.0.0.2"}]
```

### Server broadcast msg to client

> GenGameWeb.Endpoint.broadcast("ping", "try", %{yo: "adalah"})
