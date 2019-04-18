defmodule Ada.Source.News.ApiClient do
  @moduledoc false
  @base_url "http://content.guardianapis.com"
  @api_key System.get_env("GUARDIAN_API_KEY")

  alias Ada.HTTPClient

  defmodule Story do
    @moduledoc false
    defstruct title: nil,
              description: nil,
              thumbnail: nil,
              url: nil,
              pub_date: nil
  end

  def search_by_tag(tag) do
    url = Path.join([@base_url, "search"])
    qs_params = %{"tag" => tag, "show-fields" => "body,thumbnail", "api-key" => @api_key}

    case HTTPClient.json_get(url, [], qs_params) do
      %HTTPClient.Response{status_code: 200, body: body} ->
        {:ok, parse_stories(body)}

      %HTTPClient.Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}

      %HTTPClient.ErrorResponse{message: message} ->
        {:error, message}
    end
  end

  defp parse_stories(data) do
    data
    |> get_in(["response", "results"])
    |> Enum.map(fn story_data ->
      {:ok, pub_date, _} =
        story_data
        |> Map.get("webPublicationDate")
        |> DateTime.from_iso8601()

      %Story{
        title: Map.get(story_data, "webTitle"),
        description: get_in(story_data, ["fields", "body"]),
        thumbnail: get_in(story_data, ["fields", "thumbnail"]),
        url: Map.get(story_data, "webUrl"),
        pub_date: pub_date
      }
    end)
  end
end
