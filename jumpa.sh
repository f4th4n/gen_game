if [ "$1" = "api" ]; then
  docker compose exec jumpa.api iex --name "remote-1@jumpa.api" --cookie jumpa --remsh "jumpa@jumpa.api"
elif [ "$1" = "world" ]; then
  docker compose exec jumpa.world iex --name "remote-1@jumpa.world" --cookie jumpa --remsh "jumpa@jumpa.world"
elif [ "$1" = "shell" ]; then
  docker compose exec jumpa.shell bash
elif [ "$1" = "up" ]; then
  docker compose down --timeout 0
  docker compose up -d
  docker compose logs jumpa.api jumpa.world -f --tail 100
else
  echo "unknown command. available command:
	./jumpa.sh shell
	./jumpa.sh api
  ./jumpa.sh world
  ./jumpa.sh up"
fi
