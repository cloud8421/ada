defmodule Ada.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string, null: false
      add :lat, :float, null: false
      add :lng, :float, null: false

      timestamps()
    end
  end
end
