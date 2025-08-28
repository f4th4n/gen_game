# Architecture Overview

GenGame is an application with million of processes running at the same time. They also can connect with another node if needed.

```
[TODO] design overview
```

## Authorization

Authentication is supported via custom device ID and social login (Google, etc.), authorized via JWT.

# Cluster

GenGame utilize erlang distributed system to do clustering its node.

## Database

We use Postgres, as it perform well and scalable.

## In-memory data

We make sure every in-game actions always use in-memory data to maintain performance.

## Presence

GenGame use [Phoenix Presence](https://hexdocs.pm/phoenix/Phoenix.Presence.html) to decide who is online.
