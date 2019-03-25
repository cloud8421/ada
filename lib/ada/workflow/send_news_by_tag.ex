defmodule Ada.Workflow.SendNewsByTag do
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

    with user when is_present(user) <- repo.get(User, params.user_id),
         tag <- Map.get(params, :tag),
         {:ok, stories} <- News.get(%{tag: tag}) do
      {:ok, %{stories: stories, tag: tag, user: user}}
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
end
