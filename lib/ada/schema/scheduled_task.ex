defmodule Ada.Schema.ScheduledTask do
  @moduledoc """
  Represents a boilerplate for the recurring execution of a workflow.

  Captures the workflow to run, its frequency and params.

  See `t:t/0` for more details.
  """
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

  @typedoc """
  A scheduled task is mainly defined by:

  - a workflow name, deciding the workflow that needs to be run
  - a frequency, determining how often the task is run (see `Ada.Schema.Frequency`)
  - a map of params, which are going to be passed to the workflow when run
  - a transport, deciding the transport used to communicate the workflow result
    to the relevant user
  """
  @type t :: %__MODULE__{
          __meta__: term(),
          id: String.t(),
          version: pos_integer(),
          workflow_name: Workflow.t(),
          params: map(),
          transport: Workflow.transport(),
          frequency: Frequency.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc """
  Returns a changeset, starting from a scheduled task and a map of attributes to change.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(scheduled_task, params \\ %{}) do
    scheduled_task
    |> Ecto.Changeset.cast(params, [:version, :workflow_name, :params, :transport])
    |> Ecto.Changeset.cast_embed(:frequency)
    |> Ecto.Changeset.validate_required([:frequency, :workflow_name, :transport])
    |> Ecto.Changeset.validate_inclusion(:transport, Workflow.transports())
    |> Ecto.Changeset.validate_number(:version, equal_to: @task_version)
    |> Ecto.Changeset.validate_change(:workflow_name, workflow_name_validator())
  end

  @doc false
  defguard is_valid_hourly_spec?(minute, second) when minute in 0..59 and second in 0..59
  @doc false
  defguard is_valid_daily_spec?(hour, minute) when hour in 0..23 and minute in 0..59

  @doc """
  Returns true for an hourly task.
  """
  @spec hourly?(t) :: bool()
  def hourly?(%__MODULE__{frequency: frequency}), do: Frequency.hourly?(frequency)

  @doc """
  Returns true for a daily task.
  """
  @spec daily?(t) :: bool()
  def daily?(%__MODULE__{frequency: frequency}), do: Frequency.daily?(frequency)

  @doc """
  Returns true for a weekly task.
  """
  @spec weekly?(t) :: bool()
  def weekly?(%__MODULE__{frequency: frequency}), do: Frequency.weekly?(frequency)

  @doc """
  Returns true for a task that matches a given datetime, where matching is defined as:

  - same day of the week, hour and zero minutes and seconds for a weekly task
  - same hour, same minute and zero seconds for a daily task
  - same minute and second for a hourly task
  """
  @spec matches_time?(t, DateTime.t()) :: bool()
  def matches_time?(st, datetime), do: Frequency.matches_time?(st.frequency, datetime)

  @doc """
  Runs a scheduled task resolving the contained workflow.
  """
  @spec run(t, Keyword.t()) :: Workflow.run_result()
  def run(st, ctx \\ []) do
    Workflow.run(st.workflow_name, st.params, st.transport, ctx)
  end

  @doc """
  Previews the results of a scheduled task by looking at
  its raw data.
  """
  @spec preview(t, Keyword.t()) :: Workflow.raw_data_result()
  def preview(st, ctx \\ []) do
    Workflow.raw_data(st.workflow_name, st.params, ctx)
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
