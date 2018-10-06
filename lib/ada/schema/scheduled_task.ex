defmodule Ada.Schema.ScheduledTask do
  use Ecto.Schema

  @task_version 1

  defmodule Frequency do
    use Ecto.Schema

    embedded_schema do
      field :type, :string, default: "daily"
      field :hour, :integer, default: 0
      field :minute, :integer, default: 0
      field :second, :integer, default: 0
    end
  end

  schema "scheduled_tasks" do
    field :version, :integer, null: false, default: @task_version
    field :workflow_name, Ecto.Module, null: false
    field :params, :map, null: false, default: %{}
    embeds_one :frequency, Frequency

    timestamps()
  end

  @doc """
  Returns true for a task that matches a given datetime, where matching is defined as:

  - same hour, same minute and zero seconds for a daily task
  - same minute and second for a hourly task
  """
  def matches_time?(st, datetime) do
    case st.frequency do
      %{type: "daily", hour: hour, minute: minute} ->
        hour == datetime.hour and minute == datetime.minute and datetime.second == 0

      %{type: "hourly", minute: minute, second: second} ->
        minute == datetime.minute and second == datetime.second
    end
  end

  @doc """
  Performs a scheduled task resolving the contained workflow.
  """
  def execute(scheduled_task, ctx) do
    Ada.Workflow.run(scheduled_task.workflow_name, scheduled_task.params, ctx)
  end
end
