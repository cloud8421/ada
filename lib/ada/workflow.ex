defmodule Ada.Workflow do
  import Ecto.Changeset

  @type worfklow_result :: {:ok, term()} | {:error, term()}
  @type transport :: :email

  @callback human_name() :: String.t()
  @callback requirements() :: %{optional(atom()) => term()}
  @callback run(map(), transport, Keyword.t()) :: worfklow_result()

  @spec transports :: [transport]
  def transports, do: [:email]

  def run(workflow_name, params, transport, ctx) do
    with {:ok, normalized_params} <- validate(workflow_name, params),
         {:ok, result = %Ada.Email{}} <- workflow_name.run(normalized_params, transport, ctx) do
      apply_transport(result, transport, ctx)
    else
      {:ok, _non_email_result} ->
        {:error, "Workflow result is not compatible with transport"}

      error ->
        error
    end
  end

  def valid_name?(workflow_name) do
    Code.ensure_loaded?(workflow_name) and function_exported?(workflow_name, :requirements, 0) and
      function_exported?(workflow_name, :run, 3)
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

  defp apply_transport(email, :email, ctx) do
    email_api_client = Keyword.fetch!(ctx, :email_api_client)

    email_api_client.send_email(email)
  end
end
