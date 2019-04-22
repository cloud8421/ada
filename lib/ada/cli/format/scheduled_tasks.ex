defmodule Ada.CLI.Format.ScheduledTasks do
  @moduledoc false
  alias Ada.CLI.Markup

  def format_scheduled_tasks(scheduled_tasks, users, locations) do
    [
      Markup.break(),
      Markup.title("Scheduled Tasks"),
      Markup.break(),
      Enum.map(scheduled_tasks, fn st -> format_scheduled_task(st, users, locations) end)
    ]
  end

  def format_scheduled_task(scheduled_task, users, locations) do
    [
      Markup.h1("ID: #{scheduled_task.id}"),
      Markup.list_item("Workflow Name", inspect(scheduled_task.workflow_name)),
      Markup.list_item("Params", format_params(scheduled_task.params, users, locations)),
      Markup.list_item("Transport", inspect(scheduled_task.transport)),
      Markup.list_item("Frequency", format_frequency(scheduled_task.frequency)),
      Markup.break()
    ]
  end

  defp format_params(params, users, locations) do
    params
    |> Enum.map(fn
      {"location_id", location_id} ->
        format_location_param(location_id, locations)

      {"user_id", user_id} ->
        format_user_param(user_id, users)

      kv ->
        kv
    end)
  end

  defp format_location_param(location_id, locations) do
    case Enum.find(locations, fn location -> location.id == location_id end) do
      nil ->
        {"location", "not available"}

      existing ->
        {"location", existing.name}
    end
  end

  defp format_user_param(user_id, users) do
    case Enum.find(users, fn user -> user.id == user_id end) do
      nil ->
        {"user", "not available"}

      existing ->
        {"user", existing.name}
    end
  end

  defp format_frequency(frequency) do
    case frequency.type do
      "hourly" -> "Hourly, at #{frequency.minute}"
      "daily" -> "Daily, at #{frequency.hour}:#{zero_pad(frequency.minute)}"
      "weekly" -> "Every week, on #{day_name(frequency.day_of_week)} at #{frequency.hour}"
    end
  end

  defp zero_pad(int) do
    int |> Integer.to_string() |> String.pad_leading(2, "0")
  end

  defp day_name(day_of_week) do
    {:ok, days} = Calendar.DefaultTranslations.weekday_names(:en)

    Enum.at(days, day_of_week - 1)
  end
end
