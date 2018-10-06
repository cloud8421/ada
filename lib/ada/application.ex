defmodule Ada.Application do
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    ensure_data_directory!()

    children = common_children() ++ children(@target)
    opts = [strategy: :one_for_one, name: Ada.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_phase(:ensure_migrations, _type, _args) do
    Ecto.Migrator.run(Ada.Repo, migrations_path(:ada, Ada.Repo), :up, all: true)

    :ok
  end

  defp ensure_data_directory! do
    db_file = Application.get_env(:ada, Ada.Repo)[:database]
    directory = Path.dirname(db_file)
    File.mkdir_p!(directory)
  end

  defp common_children() do
    [
      Ada.PubSub.child_spec(),
      {Ada.Repo, []},
      {Ada.HTTP.Listener, [http_port: http_port(), repo: Ada.Repo]}
    ]
  end

  defp children("host") do
    [
      # Starts a worker by calling: Ada.Worker.start_link(arg)
      # {Ada.Worker, arg},
    ]
  end

  defp children(_target) do
    [
      # Starts a worker by calling: Ada.Worker.start_link(arg)
      # {Ada.Worker, arg},
    ]
  end

  defp migrations_path(app, repo) do
    lib_dir = :code.lib_dir(app)
    repo_path = Keyword.get(repo.config(), :priv, "priv/repo")

    Path.join([lib_dir, repo_path, "migrations"])
  end

  defp http_port do
    case System.get_env("HTTP_PORT") do
      nil -> 4000
      str_value -> String.to_integer(str_value)
    end
  end
end
