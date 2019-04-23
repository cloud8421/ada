defmodule Ada.Backup.Strategy do
  @moduledoc """
  The `Ada.Backup.Strategy` behaviour defines a module capable
  of backing up and restoring files from a specific provider.
  """

  @typedoc "The name to use when saving the file"
  @type name :: String.t()

  @typedoc "The path where a backup is stored"
  @type path :: String.t()

  @typedoc "The contents of the backup file"
  @type contents :: binary()

  @doc """
  This callback should check if the module is properly setup, e.g.
  if any access token is present.

  The function will be invoked at application boot. If it returns `false`,
  backups will be disabled.
  """
  @callback configured? :: boolean()

  @doc """
  Returns a list of paths where backups are stored. Each one of these paths
  should be compatible with the `download_file/1` callback.
  """
  @callback list_files() :: {:ok, [path()]} | {:error, term()}

  @doc """
  Uploads a file with the specified contents under the given name, returning
  its path.
  """
  @callback upload_file(name, contents) :: {:ok, path()} | {:error, term()}

  @doc """
  Download a file at a given path, returning its contents.
  """
  @callback download_file(path) :: {:ok, contents()} | {:error, term()}
end
