defmodule Ada.HTTP.Handler.Display.Brightness do
  @moduledoc false
  def init(req, ctx) do
    {:cowboy_rest, req, ctx}
  end

  def allowed_methods(req, ctx) do
    {["PUT", "GET"], req, ctx}
  end

  def content_types_provided(req, state) do
    {[
       {"application/json", :to_json},
       {"text/plain", :to_text}
     ], req, state}
  end

  def content_types_accepted(req, ctx) do
    {[
       {"application/json", :from_json},
       {"text/plain", :from_text}
     ], req, ctx}
  end

  def to_json(req, state) do
    body = %{brightness: Ada.Display.get_brightness()}
    {Jason.encode!(body), req, state}
  end

  def to_text(req, state) do
    body = Ada.Display.get_brightness() |> to_string()
    {body, req, state}
  end

  defguard is_valid_brightness(brightness) when brightness in 1..255

  def from_json(req, ctx) do
    {:ok, encoded, req} = :cowboy_req.read_body(req)

    with {:ok, decoded} <- Jason.decode(encoded),
         %{"brightness" => brightness} when is_valid_brightness(brightness) <- decoded do
      Ada.Display.set_brightness(brightness)
      {true, req, ctx}
    else
      _error ->
        {false, req, ctx}
    end
  end

  def from_text(req, ctx) do
    {:ok, brightness_string, req} = :cowboy_req.read_body(req)

    case Integer.parse(brightness_string) do
      {brightness, _} when is_valid_brightness(brightness) ->
        Ada.Display.set_brightness(brightness)
        {true, req, ctx}

      _error ->
        {false, req, ctx}
    end
  end
end
