defmodule Ada.Scheduler do
  use GenServer

  require Logger

  alias Ada.{Preference, PubSub, Schema.ScheduledTask, Time.Hour, Time.Minute}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def run_many_async(scheduled_tasks, opts) do
    Ada.TaskSupervisor
    |> Task.Supervisor.async_stream(scheduled_tasks, __MODULE__, :run_one_sync, [opts])
    |> Stream.run()
  end

  def run_one_sync(scheduled_task, opts) do
    PubSub.publish(Ada.ScheduledTask.Start, scheduled_task)

    case :timer.tc(ScheduledTask, :execute, [scheduled_task, opts]) do
      {elapsed_us, :ok} ->
        PubSub.publish(Ada.ScheduledTask.End, scheduled_task)
        track_success(scheduled_task, elapsed_us)
        Logger.info(fn -> "evt=st.ok id=#{scheduled_task.id}" end)

      {elapsed_us, {:ok, _value}} ->
        PubSub.publish(Ada.ScheduledTask.End, scheduled_task)
        track_success(scheduled_task, elapsed_us)
        Logger.info(fn -> "evt=st.ok id=#{scheduled_task.id}" end)

      {elapsed_us, error} ->
        PubSub.publish(Ada.ScheduledTask.End, scheduled_task)
        track_error(scheduled_task, error, elapsed_us)
        Logger.error(fn -> "evt=st.error id=#{scheduled_task.id} reason=#{inspect(error)}" end)
        error
    end
  end

  def init(opts) do
    subscribe!()

    {:ok, opts}
  end

  def handle_info({PubSub.Broadcast, Hour, datetime}, opts) do
    repo = Keyword.fetch!(opts, :repo)
    timezone = Keyword.fetch!(opts, :timezone)
    local_datetime = Calendar.DateTime.shift_zone!(datetime, timezone)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:daily, local_datetime)
    |> run_many_async(opts)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:weekly, local_datetime)
    |> run_many_async(opts)

    {:noreply, opts}
  end

  def handle_info({PubSub.Broadcast, Minute, datetime}, opts) do
    repo = Keyword.fetch!(opts, :repo)
    timezone = Keyword.fetch!(opts, :timezone)
    local_datetime = Calendar.DateTime.shift_zone!(datetime, timezone)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:hourly, local_datetime)
    |> run_many_async(opts)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:daily, local_datetime)
    |> run_many_async(opts)

    {:noreply, opts}
  end

  def handle_info({PubSub.Broadcast, Preference, {:timezone, timezone}}, opts) do
    {:noreply, Keyword.put(opts, :timezone, timezone)}
  end

  def handle_info({PubSub.Broadcast, Preference, _pair}, opts) do
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

  defp find_runnable_tasks(scheduled_tasks, :weekly, datetime) do
    scheduled_tasks
    |> Enum.filter(&ScheduledTask.weekly?/1)
    |> Enum.filter(fn st -> ScheduledTask.matches_time?(st, datetime) end)
  end

  defp subscribe! do
    PubSub.subscribe(Hour)
    PubSub.subscribe(Minute)
    PubSub.subscribe(Preference)
  end

  defp track_success(scheduled_task, elapsed_us) do
    duration = to_ms(elapsed_us)

    meta = %{
      task_id: scheduled_task.id,
      workflow: scheduled_task.workflow_name
    }

    :telemetry.execute([:scheduler, :run, :ok], %{duration: duration}, meta)
  end

  defp track_error(scheduled_task, reason, elapsed_us) do
    duration = to_ms(elapsed_us)

    meta = %{
      task_id: scheduled_task.id,
      workflow: scheduled_task.workflow_name,
      reason: reason
    }

    :telemetry.execute([:scheduler, :run, :error], %{duration: duration}, meta)
  end

  defp to_ms(us), do: div(us, 1000)
end
