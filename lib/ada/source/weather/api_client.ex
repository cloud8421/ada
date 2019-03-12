defmodule Ada.Source.Weather.ApiClient do
  @base_url "https://api.forecast.io"
  @exclude_opts "flags"
  @unit "si"
  @api_key System.get_env("FORECAST_IO_API_KEY")

  alias Ada.{HTTPClient, Source.Weather.Report, Source.Weather.DataPoint}

  def get_by_location(lat, lng) do
    lat_lng = "#{lat},#{lng}"
    url = Path.join([@base_url, "forecast", @api_key, lat_lng])
    qs_params = [{"exclude", @exclude_opts}, {"units", @unit}]

    case HTTPClient.json_get(url, [], qs_params) do
      %HTTPClient.Response{status_code: 200, body: body} ->
        {:ok, parse_response(body)}

      %HTTPClient.Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}

      %HTTPClient.ErrorResponse{message: message} ->
        {:error, message}
    end
  end

  defp parse_response(raw_data) do
    %Report{
      summary: get_in(raw_data, ["hourly", "summary"]),
      icon: get_in(raw_data, ["hourly", "icon"]),
      location: parse_location(raw_data),
      currently:
        raw_data
        |> Map.get("currently")
        |> parse_data_point,
      data_points:
        raw_data
        |> get_in(["hourly", "data"])
        |> parse_data_points
    }
  end

  defp parse_location(raw_data) do
    {Map.get(raw_data, "latitude"), Map.get(raw_data, "longitude")}
  end

  defp parse_data_points(raw_data_points) do
    for dp <- raw_data_points, do: parse_data_point(dp)
  end

  defp parse_data_point(raw_data_point) do
    %{
      "temperature" => temperature,
      "apparentTemperature" => apparent_temperature,
      "summary" => summary,
      "icon" => icon,
      "time" => timestamp
    } = raw_data_point

    %DataPoint{
      temperature: temperature,
      apparent_temperature: apparent_temperature,
      summary: summary,
      icon: icon,
      timestamp: DateTime.from_unix!(timestamp * 1000, :millisecond)
    }
  end
end
