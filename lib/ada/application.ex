defmodule Ada.Application do
  @moduledoc false

  @target Mix.Project.config()[:target]
  @env Mix.env()

  use Application

  def start(_type, _args) do
    Ada.Setup.ensure_data_directory!()
    Ada.Setup.ensure_migrations!()

    children = common_children() ++ children(@target)
    opts = [strategy: :one_for_one, name: Ada.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def http_port(env \\ @env)

  def http_port(:test), do: 4001

  def http_port(_) do
    Application.get_env(:ada, :http_port)
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

  defp listener_opts(env, target) do
    [http_port: http_port(env), repo: Ada.Repo, ui_path: ui_path(target)]
  end

  defp ui_path("host"), do: 'static/web-ui/build'
  defp ui_path(_target), do: 'static/web-ui/dist'
end
