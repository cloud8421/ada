defmodule Ada.Setup do
  def ensure_data_directory! do
    db_file()
    |> Path.dirname()
    |> File.mkdir_p!()
  end

  def ensure_migrations! do
    {:ok, pid} = Ada.Repo.start_link([])
    Ecto.Migrator.run(Ada.Repo, migrations_path(:ada, Ada.Repo), :up, all: true, log: false)
    Ada.Repo.stop(pid, 100)
  end

  def load_preferences! do
    {:ok, pid} = Ada.Repo.start_link([])
    Ada.Preferences.load_defaults!()
    preferences = Ada.Preferences.all()
    Ada.Repo.stop(pid, 100)
    preferences
  end

  def collect_vm_metrics! do
    Ada.Metrics.Vm.start()
  end

  defp db_file, do: Application.get_env(:ada, Ada.Repo)[:database]

  defp migrations_path(app, repo) do
    lib_dir = :code.lib_dir(app)
    repo_path = Keyword.get(repo.config(), :priv, "priv/repo")

    Path.join([lib_dir, repo_path, "migrations"])
  end
end
