defmodule Ada.CLI.Format do
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

  def list_scheduled_tasks(scheduled_tasks) do
    preamble = header("Scheduled Tasks")

    list =
      scheduled_tasks
      |> Enum.map(fn scheduled_task ->
        [
          list_item("ID", scheduled_task.id),
          list_item("Workflow Name", inspect(scheduled_task.workflow_name)),
          list_item("Params", format_params(scheduled_task.params)),
          list_item("Frequency", format_frequency(scheduled_task.frequency))
        ]
      end)
      |> Enum.intersperse(@break)

    :erlang.iolist_to_binary([preamble, @break, @break, list])
  end

  def scheduled_task_result({:ok, _data}) do
    header("Task run successfully")
  end

  def scheduled_task_result({:error, reason}) do
    header("Error running task: #{inspect(reason)}")
  end

  defp format_params(params) do
    params
    |> Enum.map(fn {k, v} ->
      "#{k}=#{v}"
    end)
    |> Enum.join(", ")
  end

  defp format_frequency(frequency) do
    case frequency.type do
      "hourly" -> "Hourly, at #{frequency.minute}"
      "daily" -> "Daily, at #{frequency.hour}"
      "weekly" -> "Every week, on #{day_name(frequency.day_of_week)} at #{frequency.hour}"
    end
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
end
