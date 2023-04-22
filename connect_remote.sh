if [ "$1" = "api" ]; then
  docker compose exec jumpa.api iex --name "remote-1@jumpa.api" --cookie jumpa --remsh "jumpa@jumpa.api"
elif [ "$1" = "world" ]; then
  docker compose exec jumpa.world iex --name "remote-1@jumpa.world" --cookie jumpa --remsh "jumpa@jumpa.world"
else
  echo "unknown command. available command:
	./connect_remote.sh api
	./connect_remote.sh world"
fi
