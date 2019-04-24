defmodule Ada.Email.ApiClient do
  @moduledoc """
  This module allows sending a `Ada.Email` struct via the Sendgrid API
  (documentation available at <https://sendgrid.com/docs/API_Reference/api_v3.html>).
  """

  @base_url "https://api.sendgrid.com/v3"
  @api_token System.get_env("SENDGRID_API_TOKEN")

  @doc """
  Synchronously sends an email.
  """
  @spec send_email(Ada.Email.t()) ::
          {:ok, map()}
          | {:error, :server_down, map()}
          | {:error, :unauthorized, map()}
          | {:error, :invalid_data, map()}
  def send_email(email) do
    payload =
      email
      |> to_sendgrid_payload
      |> Jason.encode!()

    url = @base_url <> "/mail/send"

    case Ada.HTTP.Client.post(url, payload, default_headers()) do
      resp = %{status_code: 202} ->
        {:ok, resp}

      resp = %{status_code: 500} ->
        {:error, :server_down, Jason.decode!(resp.body)}

      resp = %{status_code: 401} ->
        {:error, :unauthorized, Jason.decode!(resp.body)}

      resp ->
        {:error, :invalid_data, Jason.decode!(resp.body)}
    end
  end

  @doc """
  Converts an email to a sendgrid payload that can be POSTed directly.

      iex> alias Ada.Email
      iex> alias Email.ApiClient
      iex> %Email{to: ["user@example.com"], cc: ["cc@example.com"], bcc: ["bcc@example.com"], reply_to: "reply@example.com"}
      ...> |> ApiClient.to_sendgrid_payload
      %{personalizations: [%{to: [%{email: "user@example.com"}],
                             cc: [%{email: "cc@example.com"}],
                             bcc: [%{email: "bcc@example.com"}],
                             subject: "default email subject"}],
        from: %{email: "ada@fullyforged.com",
                name: "Ada"},
        reply_to: %{email: "reply@example.com"},
        content: [%{type: "text/plain",
                    value: "Plain text default body"},
                  %{type: "text/html",
                    value: "<p>html default body</p>"}]}

  """
  @spec to_sendgrid_payload(Ada.Email.t()) :: map
  def to_sendgrid_payload(email) do
    base = %{
      personalizations: [
        %{to: Enum.map(email.to, fn to -> %{email: to} end), subject: email.subject}
      ],
      from: %{
        email: email.from,
        name: email.from_name
      },
      content: [
        %{type: "text/plain", value: email.body_plain},
        %{type: "text/html", value: email.body_html}
      ]
    }

    base
    |> add_cc(email.cc)
    |> add_bcc(email.bcc)
    |> add_reply_to(email.reply_to)
  end

  defp default_headers do
    [{"Authorization", "Bearer #{@api_token}"}, {"Content-type", "application/json"}]
  end

  defp add_cc(payload, []), do: payload

  defp add_cc(payload, ccs) do
    cc_addresses = Enum.map(ccs, fn cc -> %{email: cc} end)
    put_in(payload, [:personalizations, Access.at(0), :cc], cc_addresses)
  end

  defp add_bcc(payload, []), do: payload

  defp add_bcc(payload, bccs) do
    bcc_addresses = Enum.map(bccs, fn bcc -> %{email: bcc} end)
    put_in(payload, [:personalizations, Access.at(0), :bcc], bcc_addresses)
  end

  defp add_reply_to(payload, nil), do: payload

  defp add_reply_to(payload, reply_to) do
    Map.put(payload, :reply_to, %{email: reply_to})
  end
end
