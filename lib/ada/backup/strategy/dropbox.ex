defmodule Ada.Backup.Strategy.Dropbox do
  @behaviour Ada.Backup.Strategy

  @api_token System.get_env("DROPBOX_API_TOKEN")
  @content_base_url "https://content.dropboxapi.com/2"
  @api_base_url "https://api.dropboxapi.com/2/"
  @app_namespace "/ada-v1"

  alias Ada.HTTPClient

  @impl true
  def configured? do
    @api_token !== nil
  end

  @impl true
  def list_files do
    with %HTTPClient.Response{status_code: 200, body: body} <- do_list_files(),
         {:ok, decoded} <- Jason.decode(body) do
      decoded
      |> Map.get("entries")
      |> Enum.filter(fn e -> Map.get(e, ".tag") == "file" end)
      |> Enum.map(fn e -> Map.get(e, "path_display") end)
    else
      %HTTPClient.Response{status_code: 200, body: body} ->
        Jason.decode(body)

      %HTTPClient.Response{} = response ->
        {:error, response}

      error_response ->
        error_response
    end
  end

  @impl true
  def upload_file(name, contents) do
    with %HTTPClient.Response{status_code: 200, body: body} <- do_upload_file(name, contents),
         {:ok, decoded} <- Jason.decode(body) do
      Map.fetch(decoded, "path_display")
    else
      %HTTPClient.Response{} = response ->
        {:error, response}

      error ->
        error
    end
  end

  @impl true
  def download_file(path) do
    case do_download_file(path) do
      %HTTPClient.Response{status_code: 200, body: body} ->
        {:ok, body}

      %HTTPClient.Response{} = response ->
        {:error, response}

      error_response ->
        error_response
    end
  end

  defp do_list_files() do
    body = %{"path" => @app_namespace, "recursive" => true}

    headers = %{
      "Authorization" => "Bearer #{@api_token}"
    }

    HTTPClient.post(
      @api_base_url <> "/files/list_folder",
      Jason.encode!(body),
      headers,
      'application/json'
    )
  end

  defp do_upload_file(name, contents) do
    path = Path.join([@app_namespace, name])
    dropbox_api_args = %{"path" => path, "mode" => "overwrite", "mute" => true}

    headers = %{
      "Authorization" => "Bearer #{@api_token}",
      "Dropbox-API-Arg" => Jason.encode!(dropbox_api_args)
    }

    HTTPClient.post(
      @content_base_url <> "/files/upload",
      contents,
      headers,
      'application/octet-stream'
    )
  end

  defp do_download_file(path) do
    dropbox_api_args = %{"path" => path}

    headers = %{
      "Authorization" => "Bearer #{@api_token}",
      "Dropbox-API-Arg" => Jason.encode!(dropbox_api_args)
    }

    HTTPClient.post(
      @content_base_url <> "/files/download",
      <<>>,
      headers,
      'application/octet-stream'
    )
  end
end
