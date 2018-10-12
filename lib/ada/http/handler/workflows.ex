defmodule Ada.HTTP.Handler.Workflows do
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
    body =
      Ada.Workflow.Register.names_and_requirements()
      |> with_compact_requirements()
      |> Jason.encode!()

    {body, req, ctx}
  end

  defp with_compact_requirements(names_and_requirements) do
    Enum.map(names_and_requirements, fn {name, reqs} ->
      %{name: Ada.Workflow.normalize_name(name), requirements: Map.keys(reqs)}
    end)
  end
end
