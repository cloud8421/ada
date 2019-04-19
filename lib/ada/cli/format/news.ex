defmodule Ada.CLI.Format.News do
  @moduledoc false

  alias Ada.CLI.Markup

  def format_news(tag, stories) do
    [
      Markup.title("News for #{tag}"),
      Markup.break(),
      Enum.map(stories, &format_story/1)
    ]
  end

  defp format_story(story) do
    [
      Markup.h1(story.title),
      Markup.h2(format_news_pub_date(story.pub_date)),
      Markup.h3(Markup.ellipsis(story.url, 72)),
      Markup.p(story.body_text, 72),
      Markup.break()
    ]
  end

  defp format_news_pub_date(dt) do
    Calendar.Strftime.strftime!(dt, "%R, %x")
  end
end
