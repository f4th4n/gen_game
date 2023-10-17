defmodule JumpaApp.Repo.Migrations.UpdateRoomAddToken do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :token, :string, default: ""
    end
  end
end
