defmodule Ada.Scheduler do
  use GenServer

  alias Ada.{PubSub, Schema.ScheduledTask, Time.Hour, Time.Minute}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def run_async!(scheduled_tasks, opts) do
    Ada.TaskSupervisor
    |> Task.Supervisor.async_stream(scheduled_tasks, ScheduledTask, :execute, [opts])
    |> Stream.run()
  end

  def init(opts) do
    subscribe!()

    {:ok, opts}
  end

  def handle_info({PubSub.Broadcast, Hour, datetime}, opts) do
    repo = Keyword.fetch!(opts, :repo)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:daily, datetime)
    |> run_async!(opts)

    {:noreply, opts}
  end

  def handle_info({PubSub.Broadcast, Minute, datetime}, opts) do
    repo = Keyword.fetch!(opts, :repo)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:hourly, datetime)
    |> run_async!(opts)

    {:noreply, opts}
  end

  defp find_runnable_tasks(scheduled_tasks, :hourly, datetime) do
    scheduled_tasks
    |> Enum.filter(&ScheduledTask.hourly?/1)
    |> Enum.filter(fn st -> ScheduledTask.matches_time?(st, datetime) end)
  end

  defp find_runnable_tasks(scheduled_tasks, :daily, datetime) do
    scheduled_tasks
    |> Enum.filter(&ScheduledTask.daily?/1)
    |> Enum.filter(fn st -> ScheduledTask.matches_time?(st, datetime) end)
  end

  defp subscribe! do
    PubSub.subscribe(Hour)
    PubSub.subscribe(Minute)
  end
end
