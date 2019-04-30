defmodule Ada.Email do
  @moduledoc """
  Represents an email that can be sent via different adapters.
  """
  @default_from "ada@fullyforged.com"
  @default_from_name "Ada"

  defstruct subject: "default email subject",
            to: [],
            cc: [],
            bcc: [],
            reply_to: nil,
            from: @default_from,
            from_name: @default_from_name,
            body_plain: "Plain text default body",
            body_html: "<p>html default body</p>"

  @type t :: %__MODULE__{
          subject: String.t(),
          to: [String.t()],
          cc: [String.t()],
          bcc: [String.t()],
          reply_to: nil | String.t(),
          from: String.t(),
          from_name: String.t(),
          body_plain: String.t(),
          body_html: String.t()
        }

  @doc false
  def default_from, do: @default_from

  @doc false
  def default_from_name, do: @default_from_name
end
