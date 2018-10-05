defmodule Ada.HTTP.Handler.Location do
  def init(req, ctx) do
    {:cowboy_rest, req, {:no_resource, ctx}}
  end

  def allowed_methods(req, state) do
    {["OPTIONS", "HEAD", "GET", "PUT", "PATCH"], req, state}
  end

  def resource_exists(req, {_maybe_resource, ctx} = state) do
    with repo <- Keyword.fetch!(ctx, :repo),
         {:ok, location_id} <- binding(req, :location_id),
         {:ok, location} <- find_location(repo, location_id) do
      {true, req, {location, ctx}}
    else
      _error ->
        {false, req, state}
    end
  end

  defp binding(req, name) do
    case :cowboy_req.binding(name, req) do
      :undefined -> {:error, :no_binding}
      value -> {:ok, value}
    end
  end

  defp find_location(repo, location_id) do
    case repo.get(Ada.Schema.Location, location_id) do
      nil -> {:error, :not_found}
      location -> {:ok, location}
    end
  end

  def content_types_provided(req, state) do
    {[
       {"application/json", :to_json}
     ], req, state}
  end

  def to_json(req, {location, _ctx} = state) do
    {Jason.encode!(location), req, state}
  end
end
