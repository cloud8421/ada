defmodule Ada.HTTP.Handler.Locations do
  def init(req, opts) do
    {:cowboy_rest, req, opts}
  end

  def content_types_provided(req, state) do
    {[
       {"application/json", :to_json}
     ], req, state}
  end

  def to_json(req, state) do
    body =
      Ada.Schema.Location
      |> Ada.Repo.all()
      |> Jason.encode!()

    {body, req, state}
  end
end
