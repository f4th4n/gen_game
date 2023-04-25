if [ "$1" = "api" ]; then
  docker compose exec jumpa.api iex --name "remote-1@jumpa.api" --cookie jumpa --remsh "jumpa@jumpa.api"
elif [ "$1" = "world" ]; then
  docker compose exec jumpa.world iex --name "remote-1@jumpa.world" --cookie jumpa --remsh "jumpa@jumpa.world"
elif [ "$1" = "shell" ]; then
  docker compose exec jumpa.shell bash
else
  echo "unknown command. available command:
	./jumpa.sh shell
	./jumpa.sh api
	./jumpa.sh world"
fi
