defmodule Ada.HTTP.Handler.Location.Activate do
  @moduledoc false
  def init(req, ctx) do
    {:cowboy_rest, req, {:no_location, ctx}}
  end

  def allowed_methods(req, state) do
    {["PUT", "PATCH"], req, state}
  end

  def resource_exists(req, {_maybe_location, ctx} = state) do
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

  def content_types_accepted(req, ctx) do
    {[
       {"application/json", :from_json}
     ], req, ctx}
  end

  def from_json(req, {:no_location, _ctx} = state) do
    {false, req, state}
  end

  def from_json(req, {location, ctx} = state) do
    repo = Keyword.fetch!(ctx, :repo)

    case update_locations(location, repo) do
      {:ok, result} ->
        {true, req, {result.active_set, ctx}}

      _error ->
        {false, req, state}
    end
  end

  defp update_locations(current_location, repo) do
    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:active_reset, Ada.Schema.Location, set: [active: false])
    |> Ecto.Multi.update(:active_set, Ada.Schema.Location.activate_changeset(current_location))
    |> repo.transaction()
  end
end
