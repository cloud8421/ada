defmodule Ada.UI do
  @behaviour :gen_statem

  require Logger

  @subscriptions [
    Ada.Time.Minute,
    Ada.ScheduledTask.Start,
    Ada.ScheduledTask.End,
    Ada.Preference
  ]

  alias Ada.PubSub.Broadcast
  alias Ada.UI.{Clock, TaskMon}

  defstruct display: nil,
            timezone: nil,
            local_time: nil,
            running_tasks: MapSet.new()

  ################################################################################
  ################################## PUBLIC API ##################################
  ################################################################################

  def start_link(opts) do
    :gen_statem.start_link({:local, __MODULE__}, __MODULE__, opts, [])
  end

  ################################################################################
  ################################## CALLBACKS ###################################
  ################################################################################

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def callback_mode, do: :handle_event_function

  def init(opts) do
    :ok = subscribe(@subscriptions)

    display = Keyword.fetch!(opts, :display)
    timezone = Keyword.fetch!(opts, :timezone)

    local_time = Calendar.DateTime.shift_zone!(DateTime.utc_now(), timezone)

    local_time
    |> Clock.render()
    |> display.set_content()

    {:ok, :clock, %__MODULE__{display: display, local_time: local_time, timezone: timezone}}
  end

  def handle_event(:info, {Broadcast, Ada.Time.Minute, current_utc_time}, :clock, data) do
    local_time = Calendar.DateTime.shift_zone!(current_utc_time, data.timezone)

    Logger.debug(fn ->
      "UI -> clock: new time #{DateTime.to_iso8601(local_time)}"
    end)

    local_time
    |> Clock.render()
    |> data.display.set_content()

    {:keep_state, %{data | local_time: local_time}}
  end

  def handle_event(:info, {Broadcast, Ada.ScheduledTask.Start, scheduled_task}, _state, data) do
    Logger.debug(fn ->
      "UI -> scheduled task: started task #{scheduled_task.id}"
    end)

    new_data =
      Map.update!(data, :running_tasks, fn current -> MapSet.put(current, scheduled_task.id) end)

    new_data.running_tasks
    |> TaskMon.render()
    |> data.display.set_content()

    action = {:timeout, 10000, :to_clock}

    {:keep_state, new_data, action}
  end

  def handle_event(:info, {Broadcast, Ada.ScheduledTask.End, scheduled_task}, _state, data) do
    Logger.debug(fn ->
      "UI -> scheduled task: finished task #{scheduled_task.id}"
    end)

    new_data =
      Map.update!(data, :running_tasks, fn current ->
        MapSet.delete(current, scheduled_task.id)
      end)

    new_data.running_tasks
    |> TaskMon.render()
    |> data.display.set_content()

    action =
      if Enum.empty?(new_data.running_tasks) do
        {:next_event, :internal, :to_clock}
      else
        {:timeout, 10000, :to_clock}
      end

    {:keep_state, new_data, action}
  end

  def handle_event(:info, {Broadcast, Ada.Preference, {:timezone, timezone}}, _state, data) do
    Logger.debug(fn ->
      "UI -> timezone changed to #{timezone}"
    end)

    local_time = Calendar.DateTime.shift_zone!(data.local_time, timezone)
    new_data = %{data | timezone: timezone, local_time: local_time}

    action = {:next_event, :internal, :to_clock}

    {:keep_state, new_data, action}
  end

  def handle_event(event_type, :to_clock, _state, data)
      when event_type in [:internal, :timeout] do
    Logger.debug(fn ->
      "UI -> clock: new time #{DateTime.to_iso8601(data.local_time)}"
    end)

    data.local_time
    |> Clock.render()
    |> data.display.set_content()

    {:next_state, :clock, data}
  end

  def handle_event(type, evt, state, _data) do
    Logger.debug(fn ->
      "UI -> #{state}: ignoring #{type} event: #{inspect(evt)}"
    end)

    :keep_state_and_data
  end

  ################################################################################
  ################################### PRIVATE ####################################
  ################################################################################

  defp subscribe(subscriptions) do
    Enum.each(subscriptions, &Ada.PubSub.subscribe/1)
  end
end
