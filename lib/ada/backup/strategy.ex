defmodule Ada.Backup.Strategy do
  @type name :: String.t()
  @type path :: String.t()
  @type contents :: binary()

  @callback configured? :: boolean()

  @callback list_files() :: {:ok, [path()]} | {:error, term()}

  @callback upload_file(name, contents) :: {:ok, path()} | {:error, term()}

  @callback download_file(path) :: {:ok, contents()} | {:error, term()}
end
