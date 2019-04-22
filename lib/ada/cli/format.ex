defmodule Ada.CLI.Format do
  @moduledoc false

  alias Ada.CLI.Markup

  def list_users(users) do
    Ada.CLI.Format.Users.format_users(users)
  end

  def user_created({:ok, user}) do
    display_result("Created User with ID #{user.id}")
  end

  def user_created({:error, changeset}) do
    display_result("Error creating user: #{inspect(changeset.errors)}")
  end

  def user_updated({:ok, user}) do
    display_result("Updated User with ID #{user.id}")
  end

  def user_updated({:error, changeset}) do
    display_result("Error updating user: #{inspect(changeset.errors)}")
  end

  def user_deleted({:ok, user}) do
    display_result("Deleted User with ID #{user.id}")
  end

  def user_deleted({:error, changeset}) do
    display_result("Error deleting user: #{inspect(changeset.errors)}")
  end

  def brightness_changed(:ok) do
    display_result("Brightness updated successfully")
  end

  def brightness_changed(error) do
    display_result("Error updating brightness: #{inspect(error)}")
  end

  def location_created({:ok, location}) do
    display_result("Created location with ID #{location.id}")
  end

  def location_created({:error, changeset}) do
    display_result("Error creating location: #{inspect(changeset.errors)}")
  end

  def location_updated({:ok, location}) do
    display_result("Updated location with ID #{location.id}")
  end

  def location_updated({:error, changeset}) do
    display_result("Error updating location: #{inspect(changeset.errors)}")
  end

  def location_deleted({:ok, location}) do
    display_result("Deleted location with ID #{location.id}")
  end

  def location_deleted({:error, changeset}) do
    display_result("Error deleting location: #{inspect(changeset.errors)}")
  end

  def scheduled_task_created({:ok, scheduled_task}) do
    display_result("Created scheduled_task with ID #{scheduled_task.id}")
  end

  def scheduled_task_created({:error, changeset}) do
    display_result("Error creating scheduled_task: #{inspect(changeset.errors)}")
  end

  def scheduled_task_updated({:ok, scheduled_task}) do
    display_result("Updated Scheduled Task with ID #{scheduled_task.id}")
  end

  def scheduled_task_updated({:error, changeset}) do
    display_result("Error updating Scheduled Task: #{inspect(changeset.errors)}")
  end

  def list_scheduled_tasks(scheduled_tasks, users, locations) do
    Ada.CLI.Format.ScheduledTasks.format_scheduled_tasks(scheduled_tasks, users, locations)
  end

  def scheduled_task_result(:ok) do
    display_result("Task run successfully")
  end

  def scheduled_task_result({:error, reason}) do
    display_result("Error running task: #{inspect(reason)}")
  end

  def preview({:ok, result}, %{workflow_name: Ada.Workflow.SendLastFmReport}) do
    Ada.CLI.Format.LastFm.format_report(result.report)
  end

  def preview({:ok, result}, %{workflow_name: Ada.Workflow.SendNewsByTag}) do
    Ada.CLI.Format.News.format_news(result.tag, result.stories, result.most_recent_story)
  end

  def preview({:ok, result}, %{workflow_name: Ada.Workflow.SendWeatherForecast}) do
    Ada.CLI.Format.Weather.format_report(result.weather_report, result.location)
  end

  def preview({:ok, result}, _scheduled_task), do: result

  def preview(error, _scheduled_task) do
    scheduled_task_result(error)
  end

  defp display_result(text) do
    [Markup.break(), Markup.title(text)]
  end
end
