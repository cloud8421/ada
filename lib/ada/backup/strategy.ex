defmodule Ada.Backup.Strategy do
  @type name :: String.t()
  @type contents :: String.t()

  @callback configured? :: boolean()

  @callback upload_file(name, contents) :: {:ok, term()} | {:error, term()}
end
