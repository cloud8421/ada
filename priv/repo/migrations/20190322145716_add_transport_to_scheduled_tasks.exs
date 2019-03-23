defmodule Ada.Repo.Migrations.AddTransportToScheduledTasks do
  use Ecto.Migration

  def change do
    alter table("scheduled_tasks") do
      add :transport, :string, null: false, default: "email"
    end
  end
end
