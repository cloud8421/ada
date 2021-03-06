defmodule Ada.Workflow.SendNewsByTag do
  @moduledoc false
  @behaviour Ada.Workflow
  alias Ada.Schema.User
  alias Ada.Source.News
  alias Ada.Email

  @impl true
  def human_name, do: "Send News by tag"

  @impl true
  def requirements do
    %{user_id: :integer, tag: :string}
  end

  defguard is_present(thing) when not is_nil(thing)

  @impl true
  def fetch(params, ctx) do
    repo = Keyword.fetch!(ctx, :repo)
    timezone = Keyword.fetch!(ctx, :timezone)

    with user when is_present(user) <- repo.get(User, params.user_id),
         tag <- Map.get(params, :tag),
         {:ok, stories} <- News.get(%{tag: tag}),
         stories <- localize_pub_date(stories, timezone),
         most_recent_story <- find_most_recent_story(stories) do
      {:ok, %{stories: stories, tag: tag, user: user, most_recent_story: most_recent_story}}
    end
  end

  @impl true
  def format(raw_data, :email, _ctx) do
    email_body = Email.Template.news("News for #{raw_data.tag}", raw_data.stories)
    {:ok, compose_email(raw_data.user, raw_data.tag, email_body)}
  end

  defp compose_email(user, tag, email_body) do
    %Email{
      to: [user.email],
      subject: "News for #{tag}",
      body_html: email_body
    }
  end

  defp find_most_recent_story(stories) do
    Enum.max_by(stories, fn story -> DateTime.to_unix(story.pub_date, :millisecond) end)
  end

  def localize_pub_date(stories, timezone) do
    Enum.map(stories, fn story ->
      %{story | pub_date: Calendar.DateTime.shift_zone!(story.pub_date, timezone)}
    end)
  end
end
