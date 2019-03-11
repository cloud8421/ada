defmodule Ada.HTTP.Handler.Resource do
  def init(req, ctx) do
    {:cowboy_rest, req, {:no_resource, ctx}}
  end

  def allowed_methods(req, state) do
    {["OPTIONS", "HEAD", "GET", "PUT", "PATCH", "DELETE"], req, state}
  end

  def resource_exists(req, {_maybe_resource, ctx} = state) do
    with schema <- Keyword.fetch!(ctx, :schema),
         repo <- Keyword.fetch!(ctx, :repo),
         {:ok, resource_id} <- binding(req, :resource_id),
         {:ok, resource} <- find_resource(repo, schema, resource_id) do
      {true, req, {resource, ctx}}
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

  defp find_resource(repo, schema, resource_id) do
    case repo.get(schema, resource_id) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def content_types_provided(req, state) do
    {[
       {"application/json", :to_json}
     ], req, state}
  end

  def content_types_accepted(req, ctx) do
    {[
       {"application/json", :from_json}
     ], req, ctx}
  end

  def to_json(req, {resource, _ctx} = state) do
    {Jason.encode!(resource), req, state}
  end

  def from_json(req, {:no_resource, _ctx} = state) do
    {false, req, state}
  end

  def from_json(req, {resource, ctx} = state) do
    schema = Keyword.fetch!(ctx, :schema)
    {:ok, encoded, req} = :cowboy_req.read_body(req)

    with {:ok, decoded} <- Jason.decode(encoded),
         {:ok, new_resource} <- Ada.CRUD.update(schema, resource, decoded, ctx) do
      {true, req, {new_resource, ctx}}
    else
      _error ->
        {false, req, state}
    end
  end

  def delete_resource(req, {resource, ctx} = state) do
    case Ada.CRUD.delete(resource, ctx) do
      {:ok, _} -> {true, req, {:no_resource, ctx}}
      _error -> {false, req, state}
    end
  end
end
