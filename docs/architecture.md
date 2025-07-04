# Architecture Overview

GenGame is an application with million of processes running at the same time. They also can connect with another node if needed.

```
[TODO] design overview
```

## Authorization

Currently we only support authentication with custom device ID. We authorize the user via JWT.

# Cluster

GenGame utilize erlang distributed system to do clustering its node.

## Database

We use Postgres, as it perform well and scalable.

## In-memory data

We make sure every in-game actions always use in-memory data to maintain performance.

## Presence

GenGame use [Phoenix Presence](https://hexdocs.pm/phoenix/Phoenix.Presence.html) to decide who is online.
