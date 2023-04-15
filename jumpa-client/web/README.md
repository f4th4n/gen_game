### Client channel simulation

```
ff.game.position.walkAbsolute(1, 6)
ff.game.profile.setColor('#00ff00') // TODO
```

### Deploy to Unity

Change isProd to true in src/config.json

```
shell 1
$ cd jumpa-client/web
build unity project as webgl, check "Development Build", set target folder as ~/Downloads/build
$ ./resolve-unity-build.sh
```

shell 2

```
$ http-server

then open http://localhost:3000/?player_token=abc
```
