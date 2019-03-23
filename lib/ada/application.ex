defmodule Ada.Application do
  @moduledoc false

  @target Mix.target()
  @env Mix.env()

  use Application

  def start(_type, _args) do
    # When the application crashes, only cowboy gets restarted,
    # but ranch isn't. We manually make sure that that's the case.
    Application.ensure_all_started(:ranch)
    Ada.Setup.ensure_data_directory!()
    Ada.Setup.ensure_migrations!()
    preferences = Ada.Setup.load_preferences!()

    children = common_children(preferences) ++ children(@target, preferences)
    opts = [strategy: :one_for_one, name: Ada.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def http_port(env \\ @env)

  def http_port(:test), do: 4001

  def http_port(_) do
    Application.get_env(:ada, :http_port)
  end

  defp common_children(preferences) do
    timezone = Keyword.fetch!(preferences, :timezone)

    [
      Ada.PubSub,
      Ada.TimeKeeper,
      {Ada.Repo, []},
      {Task.Supervisor, name: Ada.TaskSupervisor},
      {Ada.Scheduler,
       [repo: Ada.Repo, email_api_client: Ada.Email.ApiClient, timezone: timezone]},
      {Ada.Backup.Uploader,
       [repo: Ada.Repo, strategy: Ada.Backup.Strategy.Dropbox, timezone: timezone]},
      {Ada.HTTP.Listener, listener_opts(@env, @target, preferences)}
    ]
  end

  defp children(:host, preferences) do
    timezone = Keyword.fetch!(preferences, :timezone)

    [
      {Ada.Display, driver: Ada.Display.Driver.Dummy},
      {Ada.UI, display: Ada.Display, timezone: timezone}
      # Starts a worker by calling: Ada.Worker.start_link(arg)
      # {Ada.Worker, arg},
    ]
  end

  defp children(_device_target, preferences) do
    timezone = Keyword.fetch!(preferences, :timezone)

    [
      {Ada.Display.Driver.ScrollPhatHD, []},
      {Ada.Display, driver: Ada.Display.Driver.ScrollPhatHD},
      {Ada.UI, display: Ada.Display, timezone: timezone}
      # Starts a worker by calling: Ada.Worker.start_link(arg)
      # {Ada.Worker, arg},
    ]
  end

  defp listener_opts(env, target, preferences) do
    preferences ++
      [
        http_port: http_port(env),
        repo: Ada.Repo,
        email_api_client: Ada.Email.ApiClient,
        ui_path: ui_path(target)
      ]
  end

  defp ui_path(:host), do: 'static/web-ui/build'
  defp ui_path(_target), do: 'static/web-ui/dist'
end
