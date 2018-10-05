defmodule Ada.HTTP.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(port) do
    children = [
      Ada.HTTP.Listener.child_spec(port)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
