defmodule Ada.Workflow.SendLastFmReport do
  @behaviour Ada.Workflow

  alias Ada.Schema.User
  alias Ada.Source.LastFm
  alias Ada.Email

  @impl true
  def human_name, do: "Send a Last.Fm report"

  @impl true
  def requirements do
    %{user_id: :integer, interval_in_hours: :integer}
  end

  defguard is_present(thing) when not is_nil(thing)

  @impl true
  def run(params, :email, ctx) do
    repo = Keyword.fetch!(ctx, :repo)
    timezone = Keyword.fetch!(ctx, :timezone)

    with user when is_present(user) <- repo.get(User, params.user_id),
         interval_in_hours when is_present(interval_in_hours) <-
           Map.get(params, :interval_in_hours),
         {from, to} <- compute_interval(interval_in_hours),
         {:ok, tracks} <- LastFm.get_recent(%{user: user.last_fm_username, from: from, to: to}),
         email_body =
           Email.Template.last_fm_report(
             "LastFm report for the last #{interval_in_hours} hours",
             tracks,
             timezone
           ),
         email = compose_email(user, interval_in_hours, email_body) do
      Email.ApiClient.send_email(email)
    end
  end

  defp compute_interval(interval_in_hours) do
    interval_in_seconds = interval_in_hours * 60 * 60
    to = DateTime.utc_now()
    from = Calendar.DateTime.subtract!(to, interval_in_seconds)
    {from, to}
  end

  defp compose_email(user, interval_in_hours, email_body) do
    %Email{
      to: [user.email],
      subject: "LastFm report for the last #{interval_in_hours} hours",
      body_html: email_body
    }
  end
end
