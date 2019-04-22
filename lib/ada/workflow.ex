defmodule Ada.Workflow do
  @moduledoc """
  The Ada.Workflow module specifies a behaviour which needs to be implemented
  by all workflows.

  ## Core concepts

  A workflow has a set of requirements which define the parameters required for
  its correct execution (e.g. it may require a user id).

  It separates the **fetch** phase (gathering data) from the **format** phase
  (presenting it according to a transport, e.g. email).

  ## From idea to implementation

  One may want to fetch the list of trains starting from a specific location
  and receive them by email.

  This translates to a workflow that requires:

  - a `user_id` (to resolve the email address to send the email to)
  - a `location_id` (to fetch relevant trainline information)

  In the fetch phase, the workflow will find user and location in the local
  repo, then interact with a data source (created separately under the
  `Ada.Source` namespace) to retrieve the list of trains.

  In the format phase, this list of trains, along with any other data coming
  from the fetch phase, can be formatted according to the transport.

  It's important that all side-effectful operations (db queries, http api
  interactions, current time, etc.) are performed in the fetch phase. This way
  the format phase can be completely pure, immutable and easy to test.

  All workflow module names need to start with `Ada.Worfklow` to be correctly
  resolved by the runtime.

  ## Examples

  Please see `Ada.Worfklow.SendLastFmReport` or any other existing workflow
  module.
  """

  @type t :: module
  @type raw_data :: term()
  @type transport :: :email
  @type ctx :: Keyword.t()
  @type validation_errors :: [{atom(), Ecto.Changeset.error()}]
  @type requirements :: %{optional(atom()) => term()}

  @doc "Returns a human readable workflow name"
  @callback human_name() :: String.t()

  @doc """
  A map representing the workflow data requirements, keyed
  by the parameter name (e.g. `user_id`) and its type (`:string`).

  Supports all types handled by Ecto, as under the hood it uses Ecto's
  Changeset functions to cast and validate data. See
  <https://hexdocs.pm/ecto/2.2.9/Ecto.Schema.html#module-primitive-types> for a
  list of available types.
  """
  @callback requirements() :: requirements()

  @doc """
  Given some starting params, return data ready to be formatted.
  """
  @callback fetch(map(), ctx()) :: {:ok, raw_data()} | {:error, term()}

  @doc """
  Given some data resulting from a `fetch/2` call and a transport, return a
  result compatible with such a transport.

  For example, for a transport with value `:email`, a `{:ok, %Ada.Email{}}`
  needs to be returned for the workflow to complete successfully.
  """
  @callback format(raw_data(), transport(), ctx()) :: {:ok, term()} | {:error, term()}

  import Ecto.Changeset

  @doc """
  Returns all available transports.
  """
  @spec transports :: [transport]
  def transports, do: [:email]

  @doc """
  Runs a workflow given its name, starting params, a choice of transport and
  supporting context.

  Params are validated and formatted data is checked for compatibility with the
  chosen transport.
  """
  @spec run(t, map, transport, Keyword.t()) :: {:ok, Ada.Email.t()} | {:error, term()}
  def run(workflow_name, params, transport, ctx) do
    with {:ok, normalized_params} <- validate(workflow_name, params),
         {:ok, raw_data} <- workflow_name.fetch(normalized_params, ctx),
         {:ok, formatted_data} <- workflow_name.format(raw_data, transport, ctx),
         :ok <- validate_result(formatted_data, transport) do
      apply_transport(formatted_data, transport, ctx)
    end
  end

  @doc """
  Executes a workflow's fetch phase, returning the resulting raw data.
  """
  @spec raw_data(t, map, Keyword.t()) :: {:ok, raw_data} | {:error, term}
  def raw_data(workflow_name, params, ctx) do
    case validate(workflow_name, params) do
      {:ok, normalized_params} ->
        workflow_name.fetch(normalized_params, ctx)

      error ->
        error
    end
  end

  @doc """
  Validates that the passed module name is actually a workflow.
  """
  @spec valid_name?(t) :: boolean
  def valid_name?(workflow_name) do
    Code.ensure_loaded?(workflow_name) and
      function_exported?(workflow_name, :requirements, 0) and
      function_exported?(workflow_name, :fetch, 2) and
      function_exported?(workflow_name, :format, 3)
  end

  @doc """
  Validates a map of params according to a workflows's requirements specification.
  """
  @spec validate(t, map) :: {:ok, map} | {:error, :invalid_params, validation_errors}
  def validate(workflow_name, params) do
    changeset = validate_params(workflow_name, params)

    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, :invalid_params, changeset.errors}
    end
  end

  @doc """
  Normalizes a workflow name to string, avoiding issue in the conversion
  between a module atom and a string.
  """
  @spec normalize_name(t | String.t()) :: String.t()
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
