defmodule Ada.Source.News do
  alias Ada.Source.News.ApiClient

  def get(params) do
    ApiClient.search_by_tag(params.tag)
  end
end
