defmodule Ada.Source.LastFm.ApiClient do
  @base_url "https://ws.audioscrobbler.com/2.0"
  @api_key System.get_env("LAST_FM_API_KEY")

  alias Ada.{HTTPClient, Source.LastFm.Track}

  def get_recent(user, from, to) do
    qs_params = [
      {"method", "user.getrecenttracks"},
      {"user", user},
      {"from", DateTime.to_unix(from)},
      {"to", DateTime.to_unix(to)},
      {"api_key", @api_key},
      {"format", "json"}
    ]

    case HTTPClient.json_get(@base_url, [], qs_params) do
      %HTTPClient.Response{status_code: 200, body: body} ->
        {:ok, parse_response(body)}

      %HTTPClient.Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}

      %HTTPClient.ErrorResponse{message: message} ->
        {:error, message}
    end
  end

  defp parse_response(response) do
    tracks = get_in(response, ["recenttracks", "track"])

    tracks
    |> Enum.reverse()
    |> Enum.map(fn t ->
      listened_at = t |> get_in(["date", "uts"]) |> String.to_integer() |> DateTime.from_unix!()

      %Track{
        artist: get_in(t, ["artist", "#text"]),
        album: get_in(t, ["album", "#text"]),
        name: Map.get(t, "name"),
        listened_at: listened_at
      }
    end)
  end
end
