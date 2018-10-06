defmodule Ada.Repo.Migrations.CreateScheduledTasks do
  use Ecto.Migration

  def change do
    create table(:scheduled_tasks) do
      add :version, :integer, null: false, default: 1
      add :frequency, :string, null: false
      add :workflow_name, :string, null: false
      add :params, :string, null: false

      timestamps()
    end
  end
end
