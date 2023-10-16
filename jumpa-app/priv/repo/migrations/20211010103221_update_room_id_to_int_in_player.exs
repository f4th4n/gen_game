defmodule JumpaApp.Repo.Migrations.UpdateRoomIdToIntInPlayer do
  use Ecto.Migration

  def up do
    execute "alter table players alter room_id type int using room_id::integer, alter room_id set default 0"
  end

  def down do
    execute "alter table players alter room_id type varchar(255) using room_id, alter room_id drop default"
  end
end
