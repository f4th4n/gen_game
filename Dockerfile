FROM elixir:1.14.4

RUN mix local.hex --force && mix local.rebar --force