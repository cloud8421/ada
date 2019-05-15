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
    Ada.Setup.collect_vm_metrics!()
    preferences = Ada.Setup.load_preferences!()

    children = common_children(preferences) ++ children(preferences)
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
      {Ada.Metrics.Reporter, engine: Ada.Metrics.Engine},
      Ada.PubSub,
      Ada.TimeKeeper,
      Ada.Repo,
      {Task.Supervisor, name: Ada.TaskSupervisor},
      {Ada.Scheduler,
       repo: Ada.Repo, email_adapter: Ada.Email.Adapter.Sendgrid, timezone: timezone},
      {Ada.Backup.Uploader,
       repo: Ada.Repo, strategy: Ada.Backup.Strategy.Dropbox, timezone: timezone},
      Ada.Shortener,
      {Ada.HTTP.Listener, listener_opts(@env, preferences)}
    ]
  end

  if @target == :host do
    defp children(preferences) do
      timezone = Keyword.fetch!(preferences, :timezone)

      [
        {Ada.Display, driver: Ada.Display.Driver.Dummy},
        {Ada.UI, display: Ada.Display, timezone: timezone}
        # Starts a worker by calling: Ada.Worker.start_link(arg)
        # {Ada.Worker, arg},
      ]
    end
  else
    defp children(preferences) do
      timezone = Keyword.fetch!(preferences, :timezone)

      [
        {Ada.Display.Driver.ScrollPhatHD, []},
        {Ada.Display, driver: Ada.Display.Driver.ScrollPhatHD},
        {Ada.UI, display: Ada.Display, timezone: timezone}
        # Starts a worker by calling: Ada.Worker.start_link(arg)
        # {Ada.Worker, arg},
      ]
    end
  end

  defp listener_opts(env, preferences) do
    preferences ++
      [
        http_port: http_port(env),
        repo: Ada.Repo,
        email_adapter: Ada.Email.Adapter.Sendgrid,
        preferences_module: Ada.Preferences
      ]
  end
end
