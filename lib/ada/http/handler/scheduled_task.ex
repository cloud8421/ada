defmodule Ada.HTTP.Handler.ScheduledTask do
  def init(req, ctx) do
    {:cowboy_rest, req, {:no_resource, ctx}}
  end

  def allowed_methods(req, state) do
    {["OPTIONS", "HEAD", "GET", "PUT", "PATCH", "DELETE"], req, state}
  end

  def resource_exists(req, {_maybe_resource, ctx} = state) do
    with repo <- Keyword.fetch!(ctx, :repo),
         {:ok, scheduled_task_id} <- binding(req, :scheduled_task_id),
         {:ok, scheduled_task} <- find_scheduled_task(repo, scheduled_task_id) do
      {true, req, {scheduled_task, ctx}}
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

  defp find_scheduled_task(repo, scheduled_task_id) do
    case repo.get(Ada.Schema.ScheduledTask, scheduled_task_id) do
      nil -> {:error, :not_found}
      scheduled_task -> {:ok, scheduled_task}
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

  def to_json(req, {scheduled_task, _ctx} = state) do
    {Jason.encode!(scheduled_task), req, state}
  end

  def from_json(req, {scheduled_task, ctx} = state) do
    repo = Keyword.fetch!(ctx, :repo)
    {:ok, encoded, req} = :cowboy_req.read_body(req)

    with {:ok, decoded} <- Jason.decode(encoded),
         changeset <- Ada.Schema.ScheduledTask.changeset(scheduled_task, decoded),
         {:ok, new_scheduled_task} <- repo.update(changeset) do
      {true, req, {new_scheduled_task, ctx}}
    else
      _error ->
        {false, req, state}
    end
  end

  def delete_resource(req, {scheduled_task, ctx} = state) do
    repo = Keyword.fetch!(ctx, :repo)

    case repo.delete(scheduled_task) do
      {:ok, _} -> {true, req, {:no_resource, ctx}}
      _error -> {false, req, state}
    end
  end
end
