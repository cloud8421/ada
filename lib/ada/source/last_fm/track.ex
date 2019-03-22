defmodule Ada.Source.LastFm.Track do
  defstruct [:artist, :album, :name, :listened_at]

  @type t :: %__MODULE__{
          artist: String.t(),
          album: String.t(),
          name: String.t(),
          listened_at: :now_playing | DateTime.t()
        }

  @doc """
  Returns the artist with the highest number of tracks in the collection.
  """
  @spec most_listened_artist([t]) :: nil | String.t()
  def most_listened_artist([]), do: nil

  def most_listened_artist(tracks) do
    {artist, _tracks} =
      tracks
      |> Enum.group_by(fn track -> track.artist end)
      |> Enum.max_by(fn {_artist, artist_tracks} -> Enum.count(artist_tracks) end)

    artist
  end

  @doc """
  Group tracks by the hour.

  If there's a playing track, it's grouped in the hour corresponding to the
  local now datetime passed with the function.
  """
  @spec group_by_hour([t], Calendar.time_zone(), DateTime.t()) :: [{DateTime.t(), [t]}]
  def group_by_hour(tracks, timezone, local_now) do
    tracks
    |> Enum.group_by(fn track ->
      case track.listened_at do
        :now_playing ->
          %{local_now | minute: 0, second: 0, microsecond: {0, 0}}

        datetime ->
          local_datetime = Calendar.DateTime.shift_zone!(datetime, timezone)

          %{local_datetime | minute: 0, second: 0, microsecond: {0, 0}}
      end
    end)
    |> Enum.sort(fn {hour1, _tracks1}, {hour2, _tracks2} ->
      datetime_asc_compare(hour1, hour2)
    end)
  end

  @doc """
  Count tracks by the hour.

  If there's a playing track, it's grouped in the hour corresponding to the
  local now datetime passed with the function.
  """
  @spec count_by_hour([t], Calendar.time_zone(), DateTime.t()) :: [{DateTime.t(), pos_integer()}]
  def count_by_hour(tracks, timezone, local_now) do
    tracks
    |> group_by_hour(timezone, local_now)
    |> Enum.map(fn {hour, hour_tracks} ->
      {hour, Enum.count(hour_tracks)}
    end)
  end

  defp datetime_asc_compare(dt1, dt2) do
    case DateTime.compare(dt1, dt2) do
      :lt -> true
      :eq -> true
      :gt -> false
    end
  end
end
