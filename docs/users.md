# Users

To create or authenticate a user, see code below:

## JS

```js
function test() {
  console.log("test");
}

test();
```

## Unity / C#

```cs
var client = new Client("localhost", 4000);
await client.AuthenticateDeviceAsync("dev-123");
```
