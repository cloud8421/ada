defmodule Ada.Source.News.ApiClient do
  @moduledoc false
  @base_url "http://content.guardianapis.com"
  @api_key System.get_env("GUARDIAN_API_KEY")

  alias Ada.{HTTP, Source.News.Story}

  @spec search_by_tag(String.t()) :: {:ok, [Story.t()]} | {:error, term}
  def search_by_tag(tag) do
    url = Path.join([@base_url, "search"])
    qs_params = %{"tag" => tag, "show-fields" => "body,thumbnail", "api-key" => @api_key}

    case HTTP.Client.json_get(url, [], qs_params) do
      %HTTP.Client.Response{status_code: 200, body: body} ->
        {:ok, parse_stories(body)}

      %HTTP.Client.Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}

      %HTTP.Client.ErrorResponse{message: message} ->
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

      body_html = get_in(story_data, ["fields", "body"])

      %Story{
        title: Map.get(story_data, "webTitle"),
        body_html: body_html,
        body_text: Floki.text(body_html),
        thumbnail: get_in(story_data, ["fields", "thumbnail"]),
        url: Map.get(story_data, "webUrl"),
        pub_date: pub_date
      }
    end)
  end
end
