defmodule Ada.Repo.Migrations.CreatePreferences do
  use Ecto.Migration

  def change do
    create table("preferences", primary_key: false) do
      add :name, :string, primary_key: true
      add :value, :string, null: false

      timestamps()
    end
  end
end
