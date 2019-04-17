defmodule Ada.HTTP.Handler.Workflows do
  @moduledoc false
  def init(req, ctx) do
    {:cowboy_rest, req, ctx}
  end

  def allowed_methods(req, ctx) do
    {["GET"], req, ctx}
  end

  def content_types_provided(req, ctx) do
    {[
       {"application/json", :to_json}
     ], req, ctx}
  end

  def to_json(req, ctx) do
    workflows =
      Ada.Workflow.Register.with_requirements()
      |> with_compact_requirements()

    body = Jason.encode!(%{data: workflows})

    {body, req, ctx}
  end

  defp with_compact_requirements(names_and_requirements) do
    Enum.map(names_and_requirements, fn {workflow, reqs} ->
      %{
        name: Ada.Workflow.normalize_name(workflow),
        human_name: workflow.human_name(),
        requirements: Map.keys(reqs)
      }
    end)
  end
end
