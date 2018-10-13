defmodule Ada.Workflow do
  import Ecto.Changeset

  @type worfklow_result :: {:ok, term()} | {:error, term()}

  @callback human_name() :: String.t()
  @callback requirements() :: %{optional(atom()) => term()}
  @callback run(map(), Keyword.t()) :: worfklow_result()

  def run(workflow_name, params, ctx) do
    case validate(workflow_name, params) do
      {:ok, normalized_params} -> workflow_name.run(normalized_params, ctx)
      error -> error
    end
  end

  def valid_name?(workflow_name) do
    Code.ensure_loaded?(workflow_name) and function_exported?(workflow_name, :requirements, 0) and
      function_exported?(workflow_name, :run, 2)
  end

  def validate(workflow_name, params) do
    changeset = validate_params(workflow_name, params)

    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, :invalid_params, changeset.errors}
    end
  end

  def normalize_name(workflow_name) when is_atom(workflow_name) do
    inspect(workflow_name)
  end

  def normalize_name("Elixir." <> workflow_name), do: workflow_name
  def normalize_name(workflow_name), do: workflow_name

  defp validate_params(workflow_name, params) do
    types = workflow_name.requirements()

    {params, types}
    |> cast(params, Map.keys(types))
    |> validate_required(Map.keys(types))
  end
end
