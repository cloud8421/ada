defmodule Ada.CLI.Format.LastFm do
  @moduledoc false
  alias IO.ANSI

  @break "\n"
  @space " "
  @count_item "█"
  @left_pad "  "
  @dash "-"
  @emdash "—"
  @ellipsis "…"

  def format_report(report) do
    [
      title(report.local_now),
      @break,
      format_now_playing(report.now_playing),
      format_most_listened_artist(report.most_listened_artist),
      @break,
      format_count_by_hour(report.count_by_hour),
      @break,
      format_tracks(report.tracks)
    ]
    |> :erlang.iolist_to_binary()
  end

  defp title(local_now) do
    title = "Last.fm report"
    report_datetime = format_report_date(local_now)

    [
      @break,
      @left_pad,
      ANSI.red(),
      title,
      ANSI.reset(),
      @space,
      String.pad_leading(
        @space <> report_datetime,
        80 - String.length(@left_pad <> title),
        @emdash
      ),
      @break
    ]
  end

  defp format_now_playing(:not_playing), do: []

  defp format_now_playing({:now_playing, track}) do
    [
      @left_pad,
      ANSI.cyan(),
      "Now playing",
      @break,
      @left_pad,
      ANSI.reset(),
      format_track_item(track, @left_pad),
      @break
    ]
  end

  defp format_most_listened_artist(most_listened_artist) do
    [
      @left_pad,
      ANSI.cyan(),
      "Most listened artist",
      @break,
      @left_pad,
      ANSI.reset(),
      most_listened_artist,
      ANSI.reset(),
      @break
    ]
  end

  defp format_count_by_hour(count_by_hour) do
    [
      @left_pad,
      ANSI.cyan(),
      "Count by hour",
      ANSI.reset(),
      @break,
      format_count_by_hour_items(count_by_hour),
      ANSI.reset()
    ]
  end

  def format_count_by_hour_items(count_by_hour) do
    Enum.map(count_by_hour, fn {dt, count} ->
      [
        @left_pad,
        format_hour(dt),
        @space,
        ANSI.white(),
        String.duplicate(@count_item, count),
        @space,
        Integer.to_string(count),
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

  defp format_tracks(tracks) do
    [
      @left_pad,
      ANSI.cyan(),
      "Tracks",
      ANSI.reset(),
      @break,
      format_track_items(tracks)
    ]
  end

  defp format_track_items(tracks) do
    Enum.map(tracks, fn t ->
      [
        @left_pad,
        @dash,
        @space,
        format_track_item(t, @left_pad <> @left_pad)
      ]
    end)
  end

  defp format_track_item(track, pad) do
    [
      ANSI.yellow(),
      track.artist,
      ANSI.reset(),
      @space,
      @emdash,
      @space,
      ellipsis(track.name, 76 - String.length(track.artist)),
      @break,
      pad,
      ANSI.green(),
      ellipsis(track.album, 76),
      ANSI.reset(),
      @break
    ]
  end

  defp ellipsis(string, max_length) do
    if String.length(string) >= max_length do
      truncated_string =
        string
        |> String.slice(0, max_length - 1)
        |> String.trim_trailing()

      truncated_string <> @ellipsis
    else
      string
    end
  end
end
