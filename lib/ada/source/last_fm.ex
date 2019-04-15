defmodule Ada.Source.LastFm do
  @moduledoc false
  alias Ada.Source.LastFm.ApiClient

  def get_recent(params) do
    ApiClient.get_recent(params.user, params.from, params.to)
  end
end
