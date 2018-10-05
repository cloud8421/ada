defmodule Ada.HTTP.Handler.Locations do
  def init(req, ctx) do
    {:cowboy_rest, req, ctx}
  end

  def content_types_provided(req, ctx) do
    {[
       {"application/json", :to_json}
     ], req, ctx}
  end

  def to_json(req, ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    body =
      Ada.Schema.Location
      |> repo.all()
      |> Jason.encode!()

    {body, req, ctx}
  end
end
