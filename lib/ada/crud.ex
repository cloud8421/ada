defmodule Ada.CRUD do
  @default_ctx [repo: Ada.Repo]

  def find(schema, id, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    repo.get(schema, id)
  end

  def list(schema, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    repo.all(schema)
  end

  def create(schema, attributes, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    changeset = schema.changeset(struct(schema), attributes)
    repo.insert(changeset)
  end

  def update(schema, resource, attributes, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    changeset = schema.changeset(resource, attributes)
    repo.update(changeset)
  end

  def delete(resource, ctx \\ @default_ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    repo.delete(resource)
  end
end
