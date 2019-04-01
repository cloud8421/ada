defmodule Ada.Metrics do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = Enum.into(opts, %{})

    case state.engine.connect() do
      :ok ->
        {:ok, state}

      error ->
        log_connection_error(error, state)
        :ignore
    end
  end

  defp log_connection_error(reason, state) do
    Logger.warn(fn ->
      """
      Couldn't start the #{inspect(state.engine)} metrics sink for reason:

      #{inspect(reason)}

      The device will function normally, but its performance metrics will not
      be reported.
      """
    end)
  end
end
