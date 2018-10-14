defmodule Ada.UI do
  @behaviour :gen_statem

  require Logger

  @subscriptions [
    Ada.Time.Minute,
    Ada.ScheduledTask.Start,
    Ada.ScheduledTask.End
  ]

  alias Ada.PubSub.Broadcast
  alias Ada.UI.Clock

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

    DateTime.utc_now()
    |> Clock.render()
    |> display.set_content()

    {:ok, :clock, display}
  end

  def handle_event(:info, {Broadcast, Ada.Time.Minute, current_time}, :clock, display) do
    Logger.debug(fn ->
      "UI -> clock: new time #{DateTime.to_iso8601(current_time)}"
    end)

    current_time
    |> Clock.render()
    |> display.set_content()

    :keep_state_and_data
  end

  def handle_event(:info, {Broadcast, Ada.ScheduledTask.Start, scheduled_task}, _state, _data) do
    Logger.debug(fn ->
      "UI -> scheduled task: started task #{scheduled_task.id}"
    end)

    :keep_state_and_data
  end

  def handle_event(:info, {Broadcast, Ada.ScheduledTask.End, scheduled_task}, _state, _data) do
    Logger.debug(fn ->
      "UI -> scheduled task: finished task #{scheduled_task.id}"
    end)

    :keep_state_and_data
  end

  def handle_event(:info, evt, state, _data) do
    Logger.debug(fn ->
      "UI -> #{state}: unrecognized event: #{inspect(evt)}"
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
