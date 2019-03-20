defmodule Ada.Backup.Uploader do
  use GenServer

  require Logger

  alias Ada.{Preference, PubSub, Schema.Frequency, Time.Hour}

  # Backup every night at 3am
  @frequency %Frequency{type: "daily", hour: 3}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def run(strategy, repo) do
    db_file = repo.config()[:database]

    now = DateTime.utc_now() |> DateTime.to_iso8601()
    file_name = "#{now}/ada-v1.db"

    strategy.upload_file(file_name, File.read!(db_file))
  end

  @impl true
  def init(opts) do
    state = Enum.into(opts, %{})

    if state.strategy.configured? do
      PubSub.subscribe(Hour)
      PubSub.subscribe(Preference)
      {:ok, state}
    else
      log_non_configured_strategy(state.strategy)
      :ignore
    end
  end

  @impl true
  def handle_info({PubSub.Broadcast, Hour, datetime}, state) do
    local_datetime = Calendar.DateTime.shift_zone!(datetime, state.timezone)

    if Frequency.matches_time?(@frequency, local_datetime) do
      case run(state.strategy, state.repo) do
        {:ok, _result} ->
          log_successful_backup(local_datetime)

        {:error, reason} ->
          log_failed_backup(local_datetime, reason)
      end
    end

    {:noreply, state}
  end

  def handle_info({PubSub.Broadcast, Preference, {:timezone, timezone}}, state) do
    {:noreply, Map.put(state, :timezone, timezone)}
  end

  defp log_non_configured_strategy(strategy) do
    Logger.warn(fn ->
      """
      Couldn't start #{inspect(strategy)}, as it self-reports
      to be incorrectly configured.

      Backups will not be run for this instance.
      """
    end)
  end

  defp log_successful_backup(local_datetime) do
    Logger.info(fn -> "evt=backup.ok time=#{DateTime.to_iso8601(local_datetime)}" end)
  end

  defp log_failed_backup(local_datetime, reason) do
    Logger.error(fn ->
      "evt=backup.error time=#{DateTime.to_iso8601(local_datetime)} reason=#{inspect(reason)}"
    end)
  end
end
