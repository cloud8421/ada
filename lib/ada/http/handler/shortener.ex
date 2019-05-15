defmodule Ada.HTTP.Handler.Shortener do
  @moduledoc false

  def init(req, ctx) do
    req = maybe_reply(req)
    {:ok, req, ctx}
  end

  def maybe_reply(req) do
    case :cowboy_req.method(req) do
      "GET" ->
        find_url(req)

      _other ->
        :cowboy_req.reply(405, req)
    end
  end

  defp find_url(req) do
    with {:ok, url_id} <- binding(req, :url_id),
         {:ok, url} <- Ada.Shortener.resolve(url_id) do
      :cowboy_req.reply(302, %{"Location" => url}, req)
    else
      _error -> :cowboy_req.reply(404, req)
    end
  end

  defp binding(req, name) do
    case :cowboy_req.binding(name, req) do
      :undefined -> {:error, :no_binding}
      value -> {:ok, value}
    end
  end
end
