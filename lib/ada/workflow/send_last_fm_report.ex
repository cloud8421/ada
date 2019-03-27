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
  def fetch(params, ctx) do
    repo = Keyword.fetch!(ctx, :repo)
    timezone = Keyword.fetch!(ctx, :timezone)

    with user when is_present(user) <- repo.get(User, params.user_id),
         interval_in_hours when is_present(interval_in_hours) <-
           Map.get(params, :interval_in_hours),
         {from, to} <- compute_interval(interval_in_hours),
         {:ok, tracks} <- LastFm.get_recent(%{user: user.last_fm_username, from: from, to: to}),
         report <- build_report(tracks, timezone, to) do
      {:ok, %{report: report, interval_in_hours: interval_in_hours, user: user}}
    end
  end

  @impl true
  def format(raw_data, :email, ctx) do
    timezone = Keyword.fetch!(ctx, :timezone)

    email_body =
      Email.Template.last_fm_report(
        "LastFm report for the last #{raw_data.interval_in_hours} hours",
        raw_data.report.tracks,
        timezone
      )

    {:ok, compose_email(raw_data.user, raw_data.interval_in_hours, email_body)}
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

  defp build_report(tracks, timezone, utc_now) do
    local_now = Calendar.DateTime.shift_zone!(utc_now, timezone)

    %{
      tracks: tracks,
      now_playing: LastFm.Track.now_playing(tracks),
      most_listened_artist: LastFm.Track.most_listened_artist(tracks),
      count_by_hour: LastFm.Track.count_by_hour(tracks, timezone, local_now),
      local_now: local_now
    }
  end
end
