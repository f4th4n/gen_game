# Jumpa

## Channels

```
$ wscat -c 'ws://localhost:4000/game/websocket?vsn=2.0.0'

> ["1","1","ping","phx_join",{}]
> [null,null,"ping","send_ping",{"from_node":"server@127.0.0.2"}]
```
