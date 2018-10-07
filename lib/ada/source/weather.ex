defmodule Ada.Source.Weather do
  alias Ada.Source.Weather.ApiClient

  def get(params) do
    ApiClient.get_by_location(params.lat, params.lng)
  end
end
