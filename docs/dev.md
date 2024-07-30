# Up and Running, Dev Mode

shell 1

```bash
iex --sname gg1 -S mix phx.server
```

shell 2

```bash
HTTP_PORT=4001 iex --sname gg2 -S mix phx.server
```

# Deployment

## Docker

### Build

```bash
docker build -t f4th4n/gen_game:0.1.1 .
docker image tag f4th4n/gen_game:0.1.1 f4th4n/gen_game:latest
```

### Push

```bash
docker push f4th4n/gen_game:0.1.1
docker push f4th4n/gen_game:latest
```

## Mix

```bash
mix hex.publish
```
