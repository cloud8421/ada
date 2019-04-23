defmodule Ada.Source.LastFm.ApiClient do
  @moduledoc false
  @base_url "https://ws.audioscrobbler.com/2.0"
  @api_key System.get_env("LAST_FM_API_KEY")

  alias Ada.{HTTP, Source.LastFm.Track}

  @spec get_recent(Ada.Source.LastFm.username(), DateTime.t(), DateTime.t()) ::
          {:ok, [Track.t()]} | {:error, term()}
  def get_recent(user, from, to) do
    qs_params = [
      {"method", "user.getrecenttracks"},
      {"user", user},
      {"from", DateTime.to_unix(from)},
      {"to", DateTime.to_unix(to)},
      {"limit", "200"},
      {"api_key", @api_key},
      {"format", "json"}
    ]

    case HTTP.Client.json_get(@base_url, [], qs_params) do
      %HTTP.Client.Response{status_code: 200, body: body} ->
        {:ok, parse_response(body)}

      %HTTP.Client.Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}

      %HTTP.Client.ErrorResponse{message: message} ->
        {:error, message}
    end
  end

  @spec parse_response(map()) :: [Track.t()]
  def parse_response(response) do
    tracks = get_in(response, ["recenttracks", "track"])

    tracks
    |> Enum.reverse()
    |> Enum.map(fn t ->
      %Track{
        artist: get_in(t, ["artist", "#text"]),
        album: get_in(t, ["album", "#text"]),
        name: Map.get(t, "name"),
        listened_at: parse_listened_at(t)
      }
    end)
  end

  defp parse_listened_at(t) do
    case get_in(t, ["@attr", "nowplaying"]) do
      "true" ->
        :now_playing

      nil ->
        t |> get_in(["date", "uts"]) |> String.to_integer() |> DateTime.from_unix!()
    end
  end
end
