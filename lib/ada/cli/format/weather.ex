defmodule Ada.CLI.Format.Weather do
  @moduledoc false

  alias Ada.CLI.Markup

  def format_report(report, location) do
    next_day_of_data_points = Enum.take(report.data_points, 24)
    hours_count = Enum.count(next_day_of_data_points)

    [
      Markup.break(),
      Markup.title("Weather for #{location.name}"),
      Markup.break(),
      format_currently(report.currently),
      Markup.break(),
      format_summary(report.summary, hours_count),
      Markup.break(),
      format_data_points(next_day_of_data_points)
    ]
  end

  defp format_currently(currently) do
    [
      Markup.h1("Current conditions"),
      Markup.left_pad(),
      Markup.primary(currently.summary),
      Markup.emdash(),
      "Feels like",
      Markup.space(),
      format_temperature(currently.apparent_temperature),
      Markup.break()
    ]
  end

  defp format_summary(summary, hours_count) do
    [
      Markup.h1("Report for the next #{hours_count} hours"),
      Markup.p(summary, 72)
    ]
  end

  defp format_data_points(data_points) do
    [
      Markup.h1("Hourly forecast (Feels like)"),
      Enum.map(data_points, &format_data_point/1)
    ]
  end

  defp format_data_point(data_point) do
    [
      Markup.left_pad(),
      format_datetime(data_point.timestamp),
      Markup.space(),
      Markup.bar(round(data_point.apparent_temperature)),
      Markup.space(),
      format_temperature(data_point.apparent_temperature),
      Markup.break()
    ]
  end

  def format_temperature(temperature) do
    "#{round(temperature)}°"
  end

  defp format_datetime(datetime) do
    hour =
      datetime.hour
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    minute =
      datetime.minute
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{hour}:#{minute}"
  end
end
