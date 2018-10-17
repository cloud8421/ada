defmodule Ada.Application do
  @moduledoc false

  @target Mix.Project.config()[:target]
  @env Mix.env()

  use Application

  def start(_type, _args) do
    ensure_data_directory!()

    children = common_children() ++ children(@target)
    opts = [strategy: :one_for_one, name: Ada.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_phase(:ensure_migrations, _type, _args) do
    Ecto.Migrator.run(Ada.Repo, migrations_path(:ada, Ada.Repo), :up, all: true, log: false)

    :ok
  end

  def http_port(env \\ @env)

  def http_port(:test), do: 4001

  def http_port(_) do
    case System.get_env("HTTP_PORT") do
      nil -> 80
      str_value -> String.to_integer(str_value)
    end
  end

  defp ensure_data_directory! do
    db_file = Application.get_env(:ada, Ada.Repo)[:database]
    directory = Path.dirname(db_file)
    File.mkdir_p!(directory)
  end

  defp common_children() do
    [
      Ada.PubSub,
      Ada.TimeKeeper,
      {Ada.Repo, []},
      {Task.Supervisor, name: Ada.TaskSupervisor},
      {Ada.Scheduler, [repo: Ada.Repo]},
      {Ada.HTTP.Listener, listener_opts(@env, @target)}
    ]
  end

  defp children("host") do
    [
      {Ada.Display, driver: Ada.Display.Driver.Dummy},
      {Ada.UI, display: Ada.Display}
      # Starts a worker by calling: Ada.Worker.start_link(arg)
      # {Ada.Worker, arg},
    ]
  end

  defp children(_target) do
    [
      {Ada.Display.Driver.ScrollPhatHD, []},
      {Ada.Display, driver: Ada.Display.Driver.ScrollPhatHD},
      {Ada.UI, display: Ada.Display}
      # Starts a worker by calling: Ada.Worker.start_link(arg)
      # {Ada.Worker, arg},
    ]
  end

  defp migrations_path(app, repo) do
    lib_dir = :code.lib_dir(app)
    repo_path = Keyword.get(repo.config(), :priv, "priv/repo")

    Path.join([lib_dir, repo_path, "migrations"])
  end

  defp listener_opts(env, target) do
    [http_port: http_port(env), repo: Ada.Repo, ui_path: ui_path(target)]
  end

  defp ui_path("host"), do: 'static/web-ui/build'
  defp ui_path(_target), do: 'static/web-ui/dist'
end
