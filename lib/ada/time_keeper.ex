defmodule Ada.TimeKeeper do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ignored, name: __MODULE__)
  end

  def init(:ignored) do
    Process.send_after(self(), :tick, 1000)
    {:ok, :ignored}
  end

  def handle_info(:tick, state) do
    {elapsed, _} =
      :timer.tc(fn ->
        now = DateTime.utc_now()

        case now do
          %{minute: 0, second: 0} ->
            Ada.PubSub.publish(Ada.Time.Hour, now)
            Ada.PubSub.publish(Ada.Time.Minute, now)
            Ada.PubSub.publish(Ada.Time.Second, now)

          %{second: 0} ->
            Ada.PubSub.publish(Ada.Time.Minute, now)
            Ada.PubSub.publish(Ada.Time.Second, now)

          _other ->
            Ada.PubSub.publish(Ada.Time.Second, now)
        end
      end)

    Process.send_after(self(), :tick, 1000 - div(elapsed, 1000))
    {:noreply, state}
  end
end
