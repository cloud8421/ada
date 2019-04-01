defmodule Ada.Scheduler do
  use GenServer

  require Logger

  alias Ada.{Preference, PubSub, Schema.ScheduledTask, Time.Hour, Time.Minute}

  @task_opts [ordered: false, timeout: 10_000]

  def start_link(ctx) do
    GenServer.start_link(__MODULE__, ctx, name: __MODULE__)
  end

  def run_many_async(scheduled_tasks, ctx \\ get_ctx()) do
    Ada.TaskSupervisor
    |> Task.Supervisor.async_stream(
      scheduled_tasks,
      __MODULE__,
      :run_one_sync,
      [ctx],
      @task_opts
    )
    |> Stream.run()
  end

  def run_one_sync(scheduled_task, ctx \\ get_ctx()) do
    PubSub.publish(Ada.ScheduledTask.Start, scheduled_task)

    case :timer.tc(ScheduledTask, :run, [scheduled_task, ctx]) do
      {duration_ms, :ok} ->
        PubSub.publish(Ada.ScheduledTask.End, scheduled_task)
        track_success(scheduled_task, duration_ms)
        Logger.info(fn -> "evt=st.ok id=#{scheduled_task.id}" end)

      {duration_ms, {:ok, _value}} ->
        PubSub.publish(Ada.ScheduledTask.End, scheduled_task)
        track_success(scheduled_task, duration_ms)
        Logger.info(fn -> "evt=st.ok id=#{scheduled_task.id}" end)

      {duration_ms, error} ->
        PubSub.publish(Ada.ScheduledTask.End, scheduled_task)
        track_error(scheduled_task, error, duration_ms)
        Logger.error(fn -> "evt=st.error id=#{scheduled_task.id} reason=#{inspect(error)}" end)
        error
    end
  end

  def preview(scheduled_task, ctx \\ get_ctx()) do
    ScheduledTask.preview(scheduled_task, ctx)
  end

  def get_ctx do
    GenServer.call(__MODULE__, :get_ctx)
  end

  @impl true
  def init(ctx) do
    subscribe!()

    {:ok, ctx}
  end

  @impl true
  def handle_call(:get_ctx, _from, ctx) do
    {:reply, ctx, ctx}
  end

  @impl true
  def handle_info({PubSub.Broadcast, Hour, datetime}, ctx) do
    repo = Keyword.fetch!(ctx, :repo)
    timezone = Keyword.fetch!(ctx, :timezone)
    local_datetime = Calendar.DateTime.shift_zone!(datetime, timezone)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:weekly, local_datetime)
    |> run_many_async(ctx)

    {:noreply, ctx}
  end

  @impl true
  def handle_info({PubSub.Broadcast, Minute, datetime}, ctx) do
    repo = Keyword.fetch!(ctx, :repo)
    timezone = Keyword.fetch!(ctx, :timezone)
    local_datetime = Calendar.DateTime.shift_zone!(datetime, timezone)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:hourly, local_datetime)
    |> run_many_async(ctx)

    ScheduledTask
    |> repo.all()
    |> find_runnable_tasks(:daily, local_datetime)
    |> run_many_async(ctx)

    {:noreply, ctx}
  end

  @impl true
  def handle_info({PubSub.Broadcast, Preference, {:timezone, timezone}}, ctx) do
    {:noreply, Keyword.put(ctx, :timezone, timezone)}
  end

  @impl true
  def handle_info({PubSub.Broadcast, Preference, _pair}, ctx) do
    {:noreply, ctx}
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

  defp track_success(scheduled_task, duration_ms) do
    meta = %{
      task_id: scheduled_task.id,
      workflow: scheduled_task.workflow_name
    }

    :telemetry.execute([:scheduler, :execution, :ok], %{duration: duration_ms}, meta)
  end

  defp track_error(scheduled_task, reason, duration_ms) do
    meta = %{
      task_id: scheduled_task.id,
      workflow: scheduled_task.workflow_name,
      reason: reason
    }

    :telemetry.execute([:scheduler, :execution, :error], %{duration: duration_ms}, meta)
  end
end
