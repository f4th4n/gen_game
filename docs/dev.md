# Up and Running, Dev Mode

shell 1

```bash
iex --sname gg1 -S mix phx.server
```

shell 2

```bash
HTTP_PORT=4001 iex --sname gg2 -S mix phx.server
```