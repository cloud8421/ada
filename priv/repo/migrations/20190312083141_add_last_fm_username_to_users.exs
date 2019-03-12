defmodule Ada.Repo.Migrations.AddLastFmUsernameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:last_fm_username, :text)
    end
  end
end
