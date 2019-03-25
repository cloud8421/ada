defmodule Ada.Schema.ScheduledTask do
  use Ecto.Schema

  alias Ada.{Schema.Frequency, Workflow}

  @task_version 1

  schema "scheduled_tasks" do
    field :version, :integer, null: false, default: @task_version
    field :workflow_name, Ecto.Module, null: false
    field :params, :map, null: false, default: %{}
    field :transport, Ecto.Atom, null: false, default: :email
    embeds_one :frequency, Frequency, on_replace: :update

    timestamps()
  end

  def changeset(scheduled_task, params \\ %{}) do
    scheduled_task
    |> Ecto.Changeset.cast(params, [:version, :workflow_name, :params, :transport])
    |> Ecto.Changeset.cast_embed(:frequency)
    |> Ecto.Changeset.validate_required([:frequency, :workflow_name, :transport])
    |> Ecto.Changeset.validate_inclusion(:transport, Workflow.transports())
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
  Returns true for a daily task.
  """
  def daily?(%__MODULE__{frequency: frequency}), do: Frequency.daily?(frequency)

  @doc """
  Returns true for a weekly task.
  """
  def weekly?(%__MODULE__{frequency: frequency}), do: Frequency.weekly?(frequency)

  @doc """
  Returns true for a task that matches a given datetime, where matching is defined as:

  - same hour, same minute and zero seconds for a daily task
  - same minute and second for a hourly task
  """
  def matches_time?(st, datetime), do: Frequency.matches_time?(st.frequency, datetime)

  @doc """
  Performs a scheduled task resolving the contained workflow.
  """
  def run(st, ctx \\ []) do
    Workflow.run(st.workflow_name, st.params, st.transport, ctx)
  end

  defp workflow_name_validator do
    fn :workflow_name, workflow_name ->
      if Workflow.valid_name?(workflow_name) do
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
      |> Map.update!(:workflow_name, &Workflow.normalize_name/1)
      |> Map.put(:workflow_human_name, scheduled_task.workflow_name.human_name())
      |> Map.update!(:params, fn params ->
        Enum.map(params, fn {name, value} ->
          %{name: name, value: value}
        end)
      end)
      |> Jason.Encode.map(opts)
    end
  end
end
