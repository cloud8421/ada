defmodule Ada.CLI.Format.LastFm do
  @moduledoc false
  alias Ada.CLI.Markup

  def format_report(report) do
    [
      title(report.local_now),
      Markup.break(),
      format_now_playing(report.now_playing),
      Markup.break(),
      format_most_listened_artist(report.most_listened_artist),
      format_count_by_hour(report.count_by_hour),
      Markup.break(),
      format_tracks(report.tracks)
    ]
    |> :erlang.iolist_to_binary()
  end

  defp title(local_now) do
    left = "Last.fm report"
    right = format_report_date(local_now)

    Markup.double_title(left, right, 72)
  end

  defp format_now_playing(:not_playing), do: []

  defp format_now_playing({:now_playing, track}) do
    [
      Markup.h1("Now playing"),
      Markup.left_pad(),
      format_track_item(track, Markup.left_pad()),
      Markup.break()
    ]
  end

  defp format_most_listened_artist(most_listened_artist) do
    [
      Markup.h1("Most listened artist"),
      Markup.p(most_listened_artist, 72)
    ]
  end

  defp format_count_by_hour(count_by_hour) do
    [
      Markup.h1("Count by hour"),
      format_count_by_hour_items(count_by_hour)
    ]
  end

  def format_count_by_hour_items(count_by_hour) do
    Enum.map(count_by_hour, fn {dt, count} ->
      [
        Markup.left_pad(),
        format_hour(dt),
        Markup.space(),
        Markup.bar(count),
        Markup.space(),
        Integer.to_string(count),
        Markup.break()
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
      Markup.h1("Tracks"),
      format_track_items(tracks)
    ]
  end

  defp format_track_items(tracks) do
    Enum.map(tracks, fn t ->
      [
        Markup.left_pad(),
        Markup.dash(),
        format_track_item(t, Markup.left_pad() <> Markup.left_pad())
      ]
    end)
  end

  defp format_track_item(track, pad) do
    [
      Markup.secondary(track.artist),
      Markup.emdash(),
      Markup.ellipsis(track.name, 72 - String.length(track.artist)),
      Markup.break(),
      pad,
      Markup.tertiary(Markup.ellipsis(track.album, 72)),
      Markup.break()
    ]
  end
end
