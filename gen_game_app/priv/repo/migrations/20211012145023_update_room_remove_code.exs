defmodule GenGameApp.Repo.Migrations.UpdateRoomRemoveCode do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      remove :code
    end
  end
end
