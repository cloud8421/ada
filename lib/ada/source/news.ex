defmodule Ada.Source.News do
  @moduledoc false
  alias Ada.Source.News.{ApiClient, Story}

  @spec get(%{tag: String.t()}) :: {:ok, [Story.t()]} | {:error, term()}
  def get(params) do
    ApiClient.search_by_tag(params.tag)
  end
end
