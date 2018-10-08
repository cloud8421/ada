defmodule Ada.Source.News.ApiClient do
  @base_url "http://content.guardianapis.com"

  alias Ada.HTTPClient

  defmodule Story do
    defstruct title: nil,
              description: nil,
              thumbnail: nil,
              url: nil,
              pub_date: nil
  end

  def search_by_tag(tag) do
    url = Path.join([@base_url, "search"])
    qs_params = %{"tag" => tag, "show-fields" => "body,thumbnail", "api-key" => api_key()}

    with %HTTPClient.Response{status_code: 200, body: body} <- HTTPClient.get(url, [], qs_params),
         {:ok, data} <- Jason.decode(body) do
      {:ok, parse_stories(data)}
    else
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
      %Story{
        title: Map.get(story_data, "webTitle"),
        description: get_in(story_data, ["fields", "body"]),
        thumbnail: get_in(story_data, ["fields", "thumbnail"]),
        url: Map.get(story_data, "webUrl"),
        pub_date: Map.get(story_data, "webPublicationDate")
      }
    end)
  end

  defp api_key, do: System.get_env("GUARDIAN_API_KEY")
end
