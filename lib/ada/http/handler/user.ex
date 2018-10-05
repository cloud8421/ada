defmodule Ada.HTTP.Handler.User do
  def init(req, ctx) do
    {:cowboy_rest, req, {:no_resource, ctx}}
  end

  def allowed_methods(req, state) do
    {["OPTIONS", "HEAD", "GET", "PUT", "PATCH", "DELETE"], req, state}
  end

  def resource_exists(req, {_maybe_resource, ctx} = state) do
    with repo <- Keyword.fetch!(ctx, :repo),
         {:ok, user_id} <- binding(req, :user_id),
         {:ok, user} <- find_user(repo, user_id) do
      {true, req, {user, ctx}}
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

  defp find_user(repo, user_id) do
    case repo.get(Ada.Schema.User, user_id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
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

  def to_json(req, {user, _ctx} = state) do
    {Jason.encode!(user), req, state}
  end

  def from_json(req, {user, ctx} = state) do
    repo = Keyword.fetch!(ctx, :repo)
    {:ok, encoded, req} = :cowboy_req.read_body(req)

    with {:ok, decoded} <- Jason.decode(encoded),
         changeset <- Ada.Schema.User.update_changeset(user, decoded),
         {:ok, new_user} <- repo.update(changeset) do
      {true, req, {new_user, ctx}}
    else
      _error ->
        {false, req, state}
    end
  end

  def delete_resource(req, {user, ctx} = state) do
    repo = Keyword.fetch!(ctx, :repo)

    case repo.delete(user) do
      {:ok, _} -> {true, req, {:no_resource, ctx}}
      _error -> {false, req, state}
    end
  end
end
