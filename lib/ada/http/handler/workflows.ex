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
      |> Jason.encode!()

    {body, req, ctx}
  end
end
