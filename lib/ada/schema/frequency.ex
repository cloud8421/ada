defmodule Ada.Schema.Frequency do
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__struct__, :__meta__]}

  embedded_schema do
    field :type, :string, default: "daily"
    field :day_of_week, :integer, default: 1
    field :hour, :integer, default: 0
    field :minute, :integer, default: 0
    field :second, :integer, default: 0
  end

  def changeset(frequency, params) do
    frequency
    |> Ecto.Changeset.cast(params, [:type, :day_of_week, :hour, :minute, :second])
    |> Ecto.Changeset.validate_inclusion(:type, ["weekly", "daily", "hourly"])
    |> Ecto.Changeset.validate_inclusion(:day_of_week, 1..7)
    |> Ecto.Changeset.validate_inclusion(:hour, 0..23)
    |> Ecto.Changeset.validate_inclusion(:minute, 0..59)
    |> Ecto.Changeset.validate_inclusion(:second, 0..59)
  end

  def hourly?(frequency), do: frequency.type == "hourly"
  def daily?(frequency), do: frequency.type == "daily"
  def weekly?(frequency), do: frequency.type == "weekly"

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
