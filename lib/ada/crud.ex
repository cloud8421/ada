defmodule Ada.CRUD do
  @moduledoc """
  This module collects generalised ways to manage database entries.
  """

  @default_ctx [repo: Ada.Repo]

  alias Ada.Schema

  @type resource_id :: pos_integer()
  @type ctx :: Keyword.t()
  @type schema :: Schema.Location | Schema.ScheduledTask | Schema.User
  @type resource :: Schema.Location.t() | Schema.ScheduledTask.t() | Schema.User.t()

  @doc """
  Find a resource by its ID.
  """
  @spec find(schema, resource_id, ctx) :: resource | nil
  def find(schema, id, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    repo.get(schema, id)
  end

  @doc """
  List all resources of the same type.
  """
  @spec list(schema, ctx) :: [resource]
  def list(schema, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    repo.all(schema)
  end

  @doc """
  Create a new resource.
  """
  @spec create(schema, map(), ctx) :: {:ok, resource} | {:error, Ecto.Changeset.t()}
  def create(schema, attributes, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    changeset = schema.changeset(struct(schema), attributes)
    repo.insert(changeset)
  end

  @doc """
  Update an existing resource.
  """
  @spec update(schema, resource, map(), ctx) :: {:ok, resource} | {:error, Ecto.Changeset.t()}
  def update(schema, resource, attributes, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    changeset = schema.changeset(resource, attributes)
    repo.update(changeset)
  end

  @doc """
  Delete a resource.
  """
  @spec delete(resource, ctx) :: {:ok, resource} | {:error, Ecto.Changeset.t()}
  def delete(resource, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    repo.delete(resource)
  end
end
