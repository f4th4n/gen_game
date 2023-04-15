# Jumpa Repo

### To start API service

```
cd jumpa-api
PORT=4001 MIX_ENV=dev elixir --sname jumpa -S mix phx.server
```

attach remote shell:

```
iex --remsh jumpa --sname dev
```

### To start world service

```
cd world
PORT=4001 MIX_ENV=dev elixir --sname jumpa -S mix phx.server
```

attach remote shell:

```
iex --remsh jumpa --sname dev
```

### To start web

```
cd jumpa-client/web/
npm run start
```
