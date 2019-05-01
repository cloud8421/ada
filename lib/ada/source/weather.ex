defmodule Ada.Source.Weather do
  @moduledoc false
  alias Ada.Source.Weather.{ApiClient, Report}

  @spec get(%{lat: float, lng: float}) :: {:ok, Report.t()} | {:error, term}
  def get(params) do
    ApiClient.get_by_location(params.lat, params.lng)
  end
end
