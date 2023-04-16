if [ "$1" = "api" ]; then
  docker compose exec jumpa.api iex --name "remote-1@example.com" --cookie jumpa --remsh "jumpa@jumpa.api"
elif [ "$1" = "world" ]; then
  docker compose exec jumpa.world iex --name "remote-1@example.com" --cookie jumpa --remsh "jumpa@jumpa.world"
else
  echo "unknown command"
fi
