defmodule GenGameApp.Repo.Migrations.UpdateRoomsAddUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:rooms, [:token])
  end
end
