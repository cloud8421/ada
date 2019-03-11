defmodule Ada.HTTP.Handler.Collection do
  def init(req, ctx) do
    {:cowboy_rest, req, ctx}
  end

  def allowed_methods(req, ctx) do
    {["GET", "POST"], req, ctx}
  end

  def content_types_provided(req, ctx) do
    {[
       {"application/json", :to_json}
     ], req, ctx}
  end

  def content_types_accepted(req, ctx) do
    {[
       {"application/json", :from_json}
     ], req, ctx}
  end

  def to_json(req, ctx) do
    schema = Keyword.fetch!(ctx, :schema)

    body =
      schema
      |> Ada.CRUD.list(ctx)
      |> Jason.encode!()

    {body, req, ctx}
  end

  def from_json(req, ctx) do
    schema = Keyword.fetch!(ctx, :schema)
    {:ok, encoded, req} = :cowboy_req.read_body(req)

    with {:ok, decoded} <- Jason.decode(encoded),
         {:ok, persisted} <- Ada.CRUD.create(schema, decoded, ctx) do
      {true, set_resp_body(req, persisted), ctx}
    else
      _error ->
        {false, req, ctx}
    end
  end

  defp set_resp_body(req, resource) do
    resource
    |> Jason.encode!()
    |> :cowboy_req.set_resp_body(req)
  end
end
