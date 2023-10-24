# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GenGameApp.Repo.insert!(%GenGameApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

room1 = GenGameApp.Repo.get(GenGameApp.Game.Room, 1)

new_room = %GenGameApp.Game.Room{
  id: 1,
  region: "sea",
  token: "abc"
}

case room1 do
  nil -> GenGameApp.Repo.insert!(new_room)
  _ -> nil
end

player1 = GenGameApp.Repo.get(GenGameApp.Game.Player, 1)

new_player = %GenGameApp.Game.Player{
  id: 1,
  nick: "player1",
  pos_x: 1.0,
  pos_y: 2.0,
  token: "abc",
  room_id: 1
}

case player1 do
  nil -> GenGameApp.Repo.insert!(new_player)
  _ -> nil
end

player2 = GenGameApp.Repo.get(GenGameApp.Game.Player, 2)

new_player = %GenGameApp.Game.Player{
  id: 2,
  nick: "player2",
  pos_x: 1.0,
  pos_y: 2.0,
  token: "def",
  room_id: 1
}

case player2 do
  nil -> GenGameApp.Repo.insert!(new_player)
  _ -> nil
end
