defmodule Ada.HTTP.Handler.ExecuteScheduledTask do
  def init(req, ctx) do
    {:cowboy_rest, req, {:no_scheduled_task, ctx}}
  end

  def allowed_methods(req, state) do
    {["PUT"], req, state}
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

  def content_types_accepted(req, ctx) do
    {[
       {"application/json", :from_json}
     ], req, ctx}
  end

  def from_json(req, {:no_scheduled_task, _ctx} = state) do
    {false, req, state}
  end

  def from_json(req, {scheduled_task, ctx} = state) do
    case Ada.Schema.ScheduledTask.execute(scheduled_task, ctx) do
      :ok -> {true, req, state}
      {:ok, _value} -> {true, req, state}
      _error -> {false, req, state}
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
end
