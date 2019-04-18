defmodule Ada.HTTP.Handler.Preference do
  @moduledoc false

  def init(req, ctx) do
    {:cowboy_rest, req, {:no_name, ctx}}
  end

  def allowed_methods(req, state) do
    {["GET", "PUT"], req, state}
  end

  def resource_exists(req, {_maybe_resource, ctx} = state) do
    with {:ok, name_string} <- binding(req, :preference_name),
         {:ok, name} <- Ada.Preferences.cast(name_string) do
      {true, req, {name, ctx}}
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

  def to_json(req, {name, ctx} = state) do
    preferences_module = Keyword.fetch!(ctx, :preferences_module)
    value = preferences_module.get(name)
    {Jason.encode!(%{value: value}), req, state}
  end

  def from_json(req, {:no_name, _ctx} = state) do
    {false, req, state}
  end

  def from_json(req, {name, ctx} = state) do
    preferences_module = Keyword.fetch!(ctx, :preferences_module)
    {:ok, encoded, req} = :cowboy_req.read_body(req)

    case Jason.decode(encoded) do
      {:ok, %{"value" => value}} ->
        preferences_module.set(name, value)
        {true, req, state}

      _other_format_or_error ->
        {false, req, state}
    end
  end
end
