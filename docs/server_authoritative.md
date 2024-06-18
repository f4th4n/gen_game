# Server Authoritative

server authoritative means server doing some calculation before sending it to the client. Mostly you only need to edit file `gen_game/lib/gen_game_mod/mod.ex`, and it is safe to do so. You can use Elixir, Erland and Rust to extend GenGame.

To extend GenGame with Rust, you can use library like [rustler](https://github.com/rusterlium/rustler).

## RPC

To inject RPC call, edit `GenGameMod.Mod.rpc/1`. It will be called everytime client requets an RPC call.
