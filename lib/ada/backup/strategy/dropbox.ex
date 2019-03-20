defmodule Ada.Backup.Strategy.Dropbox do
  @behaviour Ada.Backup.Strategy

  @api_token System.get_env("DROPBOX_API_TOKEN")
  @upload_url "https://content.dropboxapi.com/2/files/upload"
  @upload_namespace "ada-v1"

  alias Ada.HTTPClient

  @impl true
  def configured? do
    @api_token !== nil
  end

  @impl true
  def upload_file(name, contents) do
    case do_upload_file(name, contents) do
      %HTTPClient.Response{status_code: 200, body: body} ->
        Jason.decode(body)

      %HTTPClient.Response{} = response ->
        {:error, response}

      error_response ->
        error_response
    end
  end

  defp do_upload_file(name, contents) do
    path = Path.join(["/", @upload_namespace, name])
    dropbox_api_args = %{"path" => path, "mode" => "overwrite", "mute" => true}

    headers = %{
      "Authorization" => "Bearer #{@api_token}",
      "Dropbox-API-Arg" => Jason.encode!(dropbox_api_args)
    }

    HTTPClient.post(@upload_url, contents, headers, 'application/octet-stream')
  end
end
