defmodule Ada.HTTPClient do
  @moduledoc """
  Simple http client based on httpc.
  """

  defmodule Response do
    @moduledoc false
    defstruct status_code: 100,
              headers: [],
              body: <<>>,
              duration: 0
  end

  defmodule ErrorResponse do
    @moduledoc false
    defstruct message: nil, duration: 0
  end

  def json_get(url, headers \\ [], qs_params \\ []) do
    headers = [{"Accept", "application/json"} | headers]

    case get(url, headers, qs_params) do
      %Response{body: <<>>} = response ->
        response

      %Response{} = response ->
        %{response | body: Jason.decode!(response.body)}

      error_response ->
        error_response
    end
  end

  def json_post(url, data, headers \\ []) do
    headers = [{"Accept", "application/json"} | headers]

    case post(url, Jason.encode!(data), headers, 'application/json') do
      %Response{body: <<>>} = response ->
        response

      %Response{} = response ->
        %{response | body: Jason.decode!(response.body)}

      error_response ->
        error_response
    end
  end

  def json_put(url, data, headers \\ []) do
    case put(url, Jason.encode!(data), headers, 'application/json') do
      %Response{body: <<>>} = response ->
        response

      %Response{} = response ->
        %{response | body: Jason.decode!(response.body)}

      error_response ->
        error_response
    end
  end

  def get(url, headers \\ [], qs_params \\ %{}) do
    headers =
      Enum.map(headers, fn {k, v} ->
        {String.to_charlist(k), String.to_charlist(v)}
      end)

    url_with_qs = url <> "?" <> URI.encode_query(qs_params)

    meta = %{url: url_with_qs, method: :get}

    :timer.tc(fn ->
      :httpc.request(:get, {String.to_charlist(url_with_qs), headers}, [], body_format: :binary)
    end)
    |> process_response(meta)
  end

  def post(url, body, headers \\ [], content_type \\ 'application/json') do
    headers =
      Enum.map(headers, fn {k, v} ->
        {String.to_charlist(k), String.to_charlist(v)}
      end)

    meta = %{url: url, method: :post}

    :timer.tc(fn ->
      :httpc.request(:post, {String.to_charlist(url), headers, content_type, body}, [],
        body_format: :binary
      )
    end)
    |> process_response(meta)
  end

  def put(url, body, headers \\ [], content_type \\ 'application/json') do
    headers =
      Enum.map(headers, fn {k, v} ->
        {String.to_charlist(k), String.to_charlist(v)}
      end)

    meta = %{url: url, method: :put}

    :timer.tc(fn ->
      :httpc.request(:put, {String.to_charlist(url), headers, content_type, body}, [],
        body_format: :binary
      )
    end)
    |> process_response(meta)
  end

  def delete(url, headers \\ []) do
    headers =
      Enum.map(headers, fn {k, v} ->
        {String.to_charlist(k), String.to_charlist(v)}
      end)

    meta = %{url: url, method: :delete}

    :timer.tc(fn ->
      :httpc.request(:delete, {String.to_charlist(url), headers, [], []}, [], body_format: :binary)
    end)
    |> process_response(meta)
  end

  defp process_response({duration_ms, {:ok, result}}, meta) do
    {{_, status, _}, headers, body} = result

    track_success(meta, status, body, duration_ms)

    headers =
      Enum.map(headers, fn {k, v} ->
        {List.to_string(k), List.to_string(v)}
      end)

    %Response{status_code: status, headers: headers, body: body, duration: duration_ms}
  end

  defp process_response({duration_ms, {:error, reason}}, meta) do
    track_failure(reason, meta, duration_ms)
    %ErrorResponse{message: reason, duration: duration_ms}
  end

  defp track_success(meta, status, body, duration) do
    uri = URI.parse(meta.url)

    metrics_meta = %{
      host: uri.host,
      method: meta.method,
      status: status
    }

    :telemetry.execute(
      [:http_client, :request, :ok],
      %{duration: duration, resp_size: byte_size(body)},
      metrics_meta
    )
  end

  defp track_failure(reason, meta, duration) do
    uri = URI.parse(meta.url)

    metrics_meta = %{
      host: uri.host,
      method: meta.method,
      reason: reason
    }

    :telemetry.execute([:http_client, :request, :error], %{duration: duration}, metrics_meta)
  end
end
