defmodule Ada.Source.LastFm.TrackTest do
  use ExUnit.Case, async: true

  alias Ada.Source.LastFm.Track

  describe "listening stats" do
    setup [:load_tracks_fixture]

    test "now_playing/1", %{tracks: tracks} do
      assert {:now_playing, %Track{name: "Russia on Ice"}} = Track.now_playing(tracks)
    end

    test "most_listened_artist/1", %{tracks: tracks} do
      assert "Porcupine Tree" == Track.most_listened_artist(tracks)
    end

    test "group_by_hour/1", %{tracks: tracks, timezone: timezone, local_now: local_now} do
      expected_hours = [
        Calendar.DateTime.from_erl!({{2019, 3, 21}, {5, 0, 0}}, timezone),
        Calendar.DateTime.from_erl!({{2019, 3, 21}, {6, 0, 0}}, timezone),
        Calendar.DateTime.from_erl!({{2019, 3, 21}, {7, 0, 0}}, timezone),
        Calendar.DateTime.from_erl!({{2019, 3, 21}, {8, 0, 0}}, timezone),
        Calendar.DateTime.from_erl!({{2019, 3, 21}, {11, 0, 0}}, timezone),
        Calendar.DateTime.from_erl!({{2019, 3, 21}, {14, 0, 0}}, timezone),
        Calendar.DateTime.from_erl!({{2019, 3, 21}, {15, 0, 0}}, timezone)
      ]

      grouped_by_hour = Track.group_by_hour(tracks, timezone, local_now)
      actual_hours = Enum.map(grouped_by_hour, fn {hour, _tracks} -> hour end)

      assert expected_hours == actual_hours

      Enum.each(grouped_by_hour, fn {_hour, tracks} ->
        assert [%Track{} | _tracks] = tracks
      end)
    end

    test "count_by_hour/1", %{tracks: tracks, timezone: timezone, local_now: local_now} do
      assert [
               {Calendar.DateTime.from_erl!({{2019, 3, 21}, {5, 0, 0}}, timezone), 6},
               {Calendar.DateTime.from_erl!({{2019, 3, 21}, {6, 0, 0}}, timezone), 10},
               {Calendar.DateTime.from_erl!({{2019, 3, 21}, {7, 0, 0}}, timezone), 8},
               {Calendar.DateTime.from_erl!({{2019, 3, 21}, {8, 0, 0}}, timezone), 3},
               {Calendar.DateTime.from_erl!({{2019, 3, 21}, {11, 0, 0}}, timezone), 15},
               {Calendar.DateTime.from_erl!({{2019, 3, 21}, {14, 0, 0}}, timezone), 7},
               {Calendar.DateTime.from_erl!({{2019, 3, 21}, {15, 0, 0}}, timezone), 2}
             ] == Track.count_by_hour(tracks, timezone, local_now)
    end
  end

  defp load_tracks_fixture(_config) do
    tracks =
      "test/fixtures/last-fm-recent-tracks.json"
      |> File.read!()
      |> Jason.decode!()
      |> Ada.Source.LastFm.ApiClient.parse_response()

    timezone = "Europe/London"

    local_now = Calendar.DateTime.from_erl!({{2019, 3, 21}, {15, 8, 36}}, timezone)

    [tracks: tracks, timezone: timezone, local_now: local_now]
  end
end
