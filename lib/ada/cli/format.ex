defmodule Ada.CLI.Format do
  @moduledoc false
  @break "\n"

  def list_users(users) do
    preamble = header("System Users")

    list =
      users
      |> Enum.map(fn user ->
        [
          list_item("ID", user.id),
          list_item("Name", user.name),
          list_item("Email", user.email),
          list_item("Last.fm", user.last_fm_username || "not set")
        ]
      end)
      |> Enum.intersperse(@break)

    :erlang.iolist_to_binary([preamble, @break, @break, list])
  end

  def user_created({:ok, user}) do
    header("Created User with ID #{user.id}")
  end

  def user_created({:error, changeset}) do
    header("Error creating user: #{inspect(changeset.errors)}")
  end

  def user_updated({:ok, user}) do
    header("Updated User with ID #{user.id}")
  end

  def user_updated({:error, changeset}) do
    header("Error updating user: #{inspect(changeset.errors)}")
  end

  def user_deleted({:ok, user}) do
    header("Deleted User with ID #{user.id}")
  end

  def user_deleted({:error, changeset}) do
    header("Error deleting user: #{inspect(changeset.errors)}")
  end

  def brightness_changed(:ok) do
    header("Brightness updated successfully")
  end

  def brightness_changed(error) do
    header("Error updating brightness: #{inspect(error)}")
  end

  def location_created({:ok, location}) do
    header("Created location with ID #{location.id}")
  end

  def location_created({:error, changeset}) do
    header("Error creating location: #{inspect(changeset.errors)}")
  end

  def scheduled_task_created({:ok, scheduled_task}) do
    header("Created scheduled_task with ID #{scheduled_task.id}")
  end

  def scheduled_task_created({:error, changeset}) do
    header("Error creating scheduled_task: #{inspect(changeset.errors)}")
  end

  def scheduled_task_updated({:ok, scheduled_task}) do
    header("Updated Scheduled Task with ID #{scheduled_task.id}")
  end

  def scheduled_task_updated({:error, changeset}) do
    header("Error updating Scheduled Task: #{inspect(changeset.errors)}")
  end

  def list_scheduled_tasks(scheduled_tasks, users, locations) do
    preamble = header("Scheduled Tasks")

    list =
      scheduled_tasks
      |> Enum.map(fn scheduled_task ->
        [
          list_item("ID", scheduled_task.id),
          list_item("Workflow Name", inspect(scheduled_task.workflow_name)),
          list_item("Params", format_params(scheduled_task.params, users, locations)),
          list_item("Transport", scheduled_task.transport),
          list_item("Frequency", format_frequency(scheduled_task.frequency))
        ]
      end)
      |> Enum.intersperse(@break)

    :erlang.iolist_to_binary([preamble, @break, @break, list])
  end

  def scheduled_task_result(:ok) do
    header("Task run successfully")
  end

  def scheduled_task_result({:error, reason}) do
    header("Error running task: #{inspect(reason)}")
  end

  def preview({:ok, result}, %{workflow_name: Ada.Workflow.SendLastFmReport}) do
    Ada.CLI.Format.LastFm.format_report(result.report)
  end

  def preview({:ok, result}, %{workflow_name: Ada.Workflow.SendNewsByTag}) do
    Ada.CLI.Format.News.format_news(result.tag, result.stories)
  end

  def preview({:ok, result}, %{workflow_name: Ada.Workflow.SendWeatherForecast}) do
    Ada.CLI.Format.Weather.format_report(result.weather_report, result.location)
  end

  def preview({:ok, result}, _scheduled_task), do: result

  def preview(error, _scheduled_task) do
    scheduled_task_result(error)
  end

  defp format_params(params, users, locations) do
    params
    |> Enum.map(fn
      {"location_id", location_id} ->
        format_location_param(location_id, locations)

      {"user_id", user_id} ->
        format_user_param(user_id, users)

      {k, v} ->
        "- #{k}: #{v}"
    end)
    |> Enum.join(padder("Params: "))
  end

  defp format_location_param(location_id, locations) do
    case Enum.find(locations, fn location -> location.id == location_id end) do
      nil -> "- location: not available"
      existing -> "- location: #{existing.name}"
    end
  end

  defp format_user_param(user_id, users) do
    case Enum.find(users, fn user -> user.id == user_id end) do
      nil -> "- user: not available"
      existing -> "- user: #{existing.name}"
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

  defp header(text) do
    IO.ANSI.magenta() <> text <> IO.ANSI.reset()
  end

  defp list_item(k, v) do
    "#{IO.ANSI.yellow()}#{k}: #{IO.ANSI.white()}#{v}#{IO.ANSI.reset()}\n"
  end

  defp padder(string) do
    padding = String.duplicate(" ", String.length(string))
    "\n#{padding}"
  end
end
