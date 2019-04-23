defmodule Ada.Source.LastFm do
  @moduledoc false
  alias Ada.Source.LastFm.ApiClient

  @type username :: String.t()
  @type params :: %{user: username, from: DateTime.t(), to: DateTime.t()}
  @type result :: {:ok, [Ada.Source.LastFm.Track.t()]} | {:error, term}

  @spec get_recent(params) :: result
  def get_recent(params) do
    ApiClient.get_recent(params.user, params.from, params.to)
  end
end
