defmodule Ada.Repo.Migrations.ModifyLocationsAddActive do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:active, :boolean, default: false)
    end
  end
end
