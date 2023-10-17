defmodule JumpaApp.Repo.Migrations.AddPosXyToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :pos_x, :float, default: 0
      add :pos_y, :float, default: 0
    end
  end
end
