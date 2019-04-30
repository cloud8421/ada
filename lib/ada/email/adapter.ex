defmodule Ada.Email.Adapter do
  @moduledoc """
  An email adapter takes a `t:Ada.Email.t/0` and sends it, reporting the
  result.
  """

  @doc """
  Synchronously sends an email.
  """
  @callback send_email(Ada.Email.t()) :: {:ok, map()} | {:error, term()}
end
