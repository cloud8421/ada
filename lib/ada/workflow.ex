defmodule Ada.Workflow do
  import Ecto.Changeset

  @type raw_data :: term()
  @type transport :: :email
  @type ctx :: Keyword.t()

  @callback human_name() :: String.t()
  @callback requirements() :: %{optional(atom()) => term()}
  @callback fetch(map(), ctx()) :: {:ok, raw_data()} | {:error, term()}
  @callback format(raw_data(), transport(), ctx()) :: {:ok, term()} | {:error, term()}

  @spec transports :: [transport]
  def transports, do: [:email]

  def run(workflow_name, params, transport, ctx) do
    with {:ok, normalized_params} <- validate(workflow_name, params),
         {:ok, raw_data} <- workflow_name.fetch(normalized_params, ctx),
         {:ok, formatted_data} <- workflow_name.format(raw_data, transport, ctx),
         :ok <- validate_result(formatted_data, transport) do
      apply_transport(formatted_data, transport, ctx)
    end
  end

  def raw_data(workflow_name, params, ctx) do
    case validate(workflow_name, params) do
      {:ok, normalized_params} ->
        workflow_name.fetch(normalized_params, ctx)

      error ->
        error
    end
  end

  def valid_name?(workflow_name) do
    Code.ensure_loaded?(workflow_name) and
      function_exported?(workflow_name, :requirements, 0) and
      function_exported?(workflow_name, :fetch, 2) and
      function_exported?(workflow_name, :format, 3)
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

  defp validate_result(%Ada.Email{}, :email), do: :ok
  defp validate_result(_incompatible_result, :email), do: {:error, :incompatible_result}

  defp apply_transport(email, :email, ctx) do
    email_api_client = Keyword.fetch!(ctx, :email_api_client)

    email_api_client.send_email(email)
  end
end
