defmodule Ada.Schema.Frequency do
  @moduledoc """
  The module expresses the idea of something that can be repeated at regular intervals.

  While it's used mainly with `Ada.Schema.ScheduledTask`, it can be applied to other use cases.

  See `t:t/0` for details.
  """
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__struct__, :__meta__]}

  embedded_schema do
    field :type, :string, default: "daily"
    field :day_of_week, :integer, default: 1
    field :hour, :integer, default: 0
    field :minute, :integer, default: 0
    field :second, :integer, default: 0
  end

  @typedoc """
  A frequency is determined by a type (hourly, daily or weekly) and day of the week, hour, minute and second.

  Depending on the type, some fields are irrelevant (e.g. minutes for a weekly frequency).
  """
  @type t :: %__MODULE__{
          id: nil | String.t(),
          type: String.t(),
          day_of_week: 1..7,
          hour: 0..23,
          minute: 0..59,
          second: 0..59
        }

  @doc """
  Returns a changeset, starting from a frequency and a map of attributes to change.
  """
  @spec changeset(t, map()) :: Ecto.Changeset.t()
  def changeset(frequency, params) do
    frequency
    |> Ecto.Changeset.cast(params, [:type, :day_of_week, :hour, :minute, :second])
    |> Ecto.Changeset.validate_inclusion(:type, ["weekly", "daily", "hourly"])
    |> Ecto.Changeset.validate_inclusion(:day_of_week, 1..7)
    |> Ecto.Changeset.validate_inclusion(:hour, 0..23)
    |> Ecto.Changeset.validate_inclusion(:minute, 0..59)
    |> Ecto.Changeset.validate_inclusion(:second, 0..59)
  end

  @doc "Returns true for a hourly frequency."
  @spec hourly?(t) :: boolean()
  def hourly?(frequency), do: frequency.type == "hourly"

  @doc "Returns true for a daily frequency."
  @spec daily?(t) :: boolean()
  def daily?(frequency), do: frequency.type == "daily"

  @doc "Returns true for a weekly frequency."
  @spec weekly?(t) :: boolean()
  def weekly?(frequency), do: frequency.type == "weekly"

  @doc """
  Returns true for a frequency that matches a given datetime, where matching is defined as:

  - same day of the week, hour and zero minutes and seconds for a weekly frequency
  - same hour, same minute and zero seconds for a daily frequency
  - same minute and second for a hourly frequency
  """
  @spec matches_time?(t, DateTime.t()) :: boolean()
  def matches_time?(frequency, datetime) do
    case frequency do
      %{type: "weekly", day_of_week: day_of_week, hour: hour} ->
        as_day_of_week =
          datetime
          |> DateTime.to_date()
          |> Date.day_of_week()

        day_of_week == as_day_of_week and hour == datetime.hour and datetime.minute == 0 and
          datetime.second == 0

      %{type: "daily", hour: hour, minute: minute} ->
        hour == datetime.hour and minute == datetime.minute and datetime.second == 0

      %{type: "hourly", minute: minute, second: second} ->
        minute == datetime.minute and second == datetime.second
    end
  end
end
