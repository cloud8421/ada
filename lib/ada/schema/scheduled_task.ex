defmodule Ada.Schema.ScheduledTask do
  use Ecto.Schema

  alias Ada.Schema.Frequency

  @task_version 1

  schema "scheduled_tasks" do
    field :version, :integer, null: false, default: @task_version
    field :workflow_name, Ecto.Module, null: false
    field :params, :map, null: false, default: %{}
    embeds_one :frequency, Frequency

    timestamps()
  end

  def changeset(scheduled_task, params \\ %{}) do
    scheduled_task
    |> Ecto.Changeset.cast(params, [:version, :workflow_name, :params])
    |> Ecto.Changeset.cast_embed(:frequency)
    |> Ecto.Changeset.validate_required([:frequency, :workflow_name])
    |> Ecto.Changeset.validate_number(:version, equal_to: @task_version)
    |> Ecto.Changeset.validate_change(:workflow_name, workflow_name_validator())
  end

  defguard is_valid_hourly_spec?(minute, second) when minute in 0..59 and second in 0..59
  defguard is_valid_daily_spec?(hour, minute) when hour in 0..23 and minute in 0..59

  @doc """
  Returns true for an hourly task.
  """
  def hourly?(%__MODULE__{frequency: frequency}), do: Frequency.hourly?(frequency)

  @doc """
  Returns true for an daily task.
  """
  def daily?(%__MODULE__{frequency: frequency}), do: Frequency.daily?(frequency)

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
  def execute(scheduled_task, ctx \\ []) do
    Ada.Workflow.run(scheduled_task.workflow_name, scheduled_task.params, ctx)
  end

  defp workflow_name_validator do
    fn :workflow_name, workflow_name ->
      if Ada.Workflow.valid_name?(workflow_name) do
        []
      else
        [workflow_name: "workflow name is invalid"]
      end
    end
  end

  defimpl Jason.Encoder do
    def encode(scheduled_task, opts) do
      scheduled_task
      |> Map.drop([:__struct__, :__meta__])
      |> Map.update!(:workflow_name, &Ada.Workflow.normalize_name/1)
      |> Map.update!(:params, fn params ->
        Enum.map(params, fn {name, value} ->
          %{name: name, value: value}
        end)
      end)
      |> Jason.Encode.map(opts)
    end
  end
end
