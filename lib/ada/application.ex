defmodule Ada.Application do
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Ada.Supervisor]
    children = common_children() ++ children(@target)
    Supervisor.start_link(children, opts)
  end

  def common_children do
    [
      {Ada.Repo, []}
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
end
