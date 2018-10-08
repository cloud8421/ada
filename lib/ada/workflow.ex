defmodule Ada.Workflow do
  import Ecto.Changeset

  @type worfklow_result :: {:ok, term()} | {:error, term()}

  @callback requirements() :: %{optional(atom()) => term()}
  @callback run(map(), Keyword.t()) :: worfklow_result()

  def run(workflow_name, params, ctx) do
    case validate(workflow_name, params) do
      {:ok, normalized_params} -> workflow_name.run(normalized_params, ctx)
      error -> error
    end
  end

  def validate(workflow_name, params) do
    changeset = validate_params(workflow_name, params)

    if changeset.valid? do
      {:ok, changeset.changes}
    else
      {:error, :invalid_params, changeset.errors}
    end
  end

  defp validate_params(workflow_name, params) do
    types = workflow_name.requirements()

    {params, types}
    |> cast(params, Map.keys(types))
    |> validate_required(Map.keys(types))
  end
end
