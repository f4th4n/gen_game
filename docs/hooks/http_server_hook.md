---
sidebar_position: 3
---

# HTTP Server Hook

GenGame can be extended with any programming language as long as they have network. Every messages will be passed to your server via HTTP protocol.

## Environment Variables

1. HTTP_HOOK_HOST

Your HTTP web server host, default to `localhost`.

2. HTTP_HOOK_PORT

Your HTTP web server port, default to `9500`.

3. HTTP_HOOK_SCHEME

Your HTTP web server port, default to `http`.

## Specifications

GenGame will make a request to your web server with both event name and its payload. Eevery request request will be made at "POST / HTTP/1.1". Before you send any response, you can do any action like logging the user, adding some data, etc. And then you respond the request with proper structure, which we'll explain soon.

You can read every available hooks [here](https://gengame.rbs8.com/docs/hooks), with the detail, payload and what you should response.

Here is example of request, when there is `before_create_match` event:

POST / HTTP/1.1
Host: localhost:9500
Content-Type: application/application/json

```json
{
  "username": "john",
  "match_id": "123"
}
```

You should respond the request with something like this:

```json
{
  "username": "john",
  "match_id": "123"
}
```

## Example

We put simple project to demonstrate HTTP hooks. It is NodeJS app that expose HTTP server. You can see the project [here](https://github.com/f4th4n/gen_game/tree/master/examples/http_hook_example).
