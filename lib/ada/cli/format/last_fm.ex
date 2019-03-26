defmodule Ada.CLI.Format.LastFm do
  alias IO.ANSI

  @break "\n"
  @space " "
  @count_item "█"
  @left_pad "  "

  def format_report(report) do
    title = "Last.fm report"
    report_datetime = format_report_date(report.local_now)

    [
      [
        @left_pad,
        ANSI.red(),
        "Last.fm report",
        ANSI.reset(),
        String.pad_leading(report_datetime, 80 - String.length(@left_pad <> title)),
        @break
      ],
      @break,
      [
        @left_pad,
        ANSI.cyan(),
        "Most listened artist",
        @break,
        @left_pad,
        ANSI.reset(),
        report.most_listened_artist,
        ANSI.reset(),
        @break
      ],
      [
        @left_pad,
        ANSI.cyan(),
        "Count by hour",
        ANSI.reset(),
        @break,
        format_count_by_hour(report.count_by_hour),
        ANSI.reset(),
        @break
      ]
    ]
    |> :erlang.iolist_to_binary()
  end

  defp format_count_by_hour(count_by_hour) do
    Enum.map(count_by_hour, fn {dt, count} ->
      [
        @left_pad,
        format_hour(dt),
        @space,
        ANSI.white(),
        String.duplicate(@count_item, count),
        ANSI.reset(),
        @break
      ]
    end)
  end

  defp format_report_date(dt) do
    Calendar.Strftime.strftime!(dt, "%R, %x")
  end

  defp format_hour(dt) do
    Calendar.Strftime.strftime!(dt, "%x, %H:00")
  end
end
