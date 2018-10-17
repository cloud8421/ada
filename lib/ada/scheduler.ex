defmodule Ada.Scheduler do
  use GenServer

  require Logger

  alias Ada.{PubSub, Schema.ScheduledTask, Time.Hour, Time.Minute}

  @timezone "Europe/London"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def run_many_async(scheduled_tasks, opts) do
    Ada.TaskSupervisor
    |> Task.Supervisor.async_stream(scheduled_tasks, __MODULE__, :run_now!, [opts])
    |> Stream.run()
  end

  def run_one_sync(scheduled_task, opts) do
    PubSub.publish(Ada.ScheduledTask.Start, scheduled_task)

    case ScheduledTask.execute(scheduled_task, opts) do
      :ok ->
        PubSub.publish(Ada.ScheduledTask.End, scheduled_task)
        Logger.info(fn -> "evt=st.ok id=#{scheduled_task.id}" end)

      {:ok, _value} ->
        PubSub.publish(Ada.ScheduledTask.End, scheduled_task)
        Logger.info(fn -> "evt=st.ok id=#{scheduled_task.id}" end)

      {:error, reason} = error ->
        PubSub.publish(Ada.ScheduledTask.End, scheduled_task)
        Logger.error(fn -> "evt=st.error id=#{scheduled_task.id} reason=#{inspect(reason)}" end)
        error
    end
  end

  def init(opts) do
    subscribe!()

    {:ok, opts}
  end

  def handle_info({PubSub.Broadcast, Hour, datetime}, opts) do
    repo = Keyword.fetch!(opts, :repo)
    local_datetime = Calendar.DateTime.shift_zone!(datetime, @timezone)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:daily, local_datetime)
    |> run_many_async(opts)

    {:noreply, opts}
  end

  def handle_info({PubSub.Broadcast, Minute, datetime}, opts) do
    repo = Keyword.fetch!(opts, :repo)
    local_datetime = Calendar.DateTime.shift_zone!(datetime, @timezone)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:hourly, local_datetime)
    |> run_many_async(opts)

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
