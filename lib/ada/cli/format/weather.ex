defmodule Ada.CLI.Format.Weather do
  @moduledoc false

  alias IO.ANSI

  @break "\n"
  @space " "
  @count_item "█"
  @left_pad "  "
  @emdash "—"

  def format_report(report, location) do
    next_day_of_data_points = Enum.take(report.data_points, 24)
    hours_count = Enum.count(next_day_of_data_points)

    [
      title(location),
      @break,
      format_currently(report.currently),
      @break,
      format_summary(report.summary, hours_count),
      @break,
      format_data_points(next_day_of_data_points)
    ]
  end

  defp title(location) do
    [
      @break,
      @left_pad,
      ANSI.red(),
      "Weather for",
      @space,
      location.name,
      ANSI.reset(),
      @break
    ]
  end

  defp format_currently(currently) do
    [
      @left_pad,
      ANSI.cyan(),
      "Current conditions",
      ANSI.reset(),
      @break,
      @left_pad,
      ANSI.yellow(),
      currently.summary,
      ANSI.reset(),
      @space,
      @emdash,
      @space,
      "Feels like",
      @space,
      format_temperature(currently.apparent_temperature),
      @break
    ]
  end

  defp format_summary(summary, hours_count) do
    [
      @left_pad,
      ANSI.cyan(),
      "Report for the next #{hours_count} hours",
      ANSI.reset(),
      @break,
      @left_pad,
      summary,
      @break
    ]
  end

  # %Ada.Source.Weather.DataPoint{
  #   apparent_temperature: 5.31,
  #   icon: "partly-cloudy-day",
  #   summary: "Partly Cloudy",
  #   temperature: 8.06,
  #   timestamp: #DateTime<2019-04-19 05:18:53.000Z>
  # }
  defp format_data_points(data_points) do
    [
      @left_pad,
      ANSI.cyan(),
      "Hourly forecast (Feels like)",
      ANSI.reset(),
      @break,
      Enum.map(data_points, &format_data_point/1)
    ]
  end

  defp format_data_point(data_point) do
    [
      @left_pad,
      format_datetime(data_point.timestamp),
      @space,
      String.duplicate(@count_item, round(data_point.apparent_temperature)),
      @space,
      format_temperature(data_point.apparent_temperature),
      @break
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

  # defp format_stories(stories) do
  #   Enum.map(stories, &format_story/1)
  # end
  #
  # defp format_story(story) do
  #   [
  #     @left_pad,
  #     ANSI.yellow(),
  #     story.title,
  #     ANSI.reset(),
  #     @break,
  #     @left_pad,
  #     ANSI.cyan(),
  #     format_news_pub_date(story.pub_date),
  #     ANSI.reset(),
  #     @break,
  #     @left_pad,
  #     ANSI.green(),
  #     ellipsis(story.url, 72),
  #     ANSI.reset(),
  #     @break,
  #     ANSI.white(),
  #     WordWrap.paragraph(story.body_text, 72, @left_pad),
  #     ANSI.reset(),
  #     @break
  #   ]
  # end
  #
  # defp format_news_pub_date(dt) do
  #   Calendar.Strftime.strftime!(dt, "%R, %x")
  # end
  #
  # defp ellipsis(string, max_length) do
  #   if String.length(string) >= max_length do
  #     truncated_string =
  #       string
  #       |> String.slice(0, max_length - 1)
  #       |> String.trim_trailing()
  #
  #     truncated_string <> @ellipsis
  #   else
  #     string
  #   end
  # end
end
