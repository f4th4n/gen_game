## Build the docker env
start:
	docker compose down &&\
	docker compose up -d &&\
	docker logs -f gen_game

console:
	docker compose exec gen_game iex --sname remote_1 --remsh gen_game

restart_app:
	docker compose stop gen_game --timeout 0 &&\
	docker compose up -d &&\
	docker logs -f gen_game
