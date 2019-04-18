defmodule Ada.CLI.Format.News do
  @moduledoc false

  alias IO.ANSI
  alias Ada.CLI.Format.WordWrap

  @break "\n"
  @space " "
  @left_pad "  "
  @ellipsis "…"

  def format_news(tag, stories) do
    [
      title(tag),
      @break,
      format_stories(stories)
    ]
  end

  defp title(tag) do
    [
      @break,
      @left_pad,
      ANSI.red(),
      "News for",
      @space,
      tag,
      ANSI.reset(),
      @break
    ]
  end

  defp format_stories(stories) do
    Enum.map(stories, &format_story/1)
  end

  defp format_story(story) do
    [
      @left_pad,
      ANSI.yellow(),
      story.title,
      ANSI.reset(),
      @break,
      @left_pad,
      ANSI.cyan(),
      format_news_pub_date(story.pub_date),
      ANSI.reset(),
      @break,
      @left_pad,
      ANSI.green(),
      ellipsis(story.url, 72),
      ANSI.reset(),
      @break,
      ANSI.white(),
      WordWrap.paragraph(story.body_text, 72, @left_pad),
      ANSI.reset(),
      @break
    ]
  end

  defp format_news_pub_date(dt) do
    Calendar.Strftime.strftime!(dt, "%R, %x")
  end

  defp ellipsis(string, max_length) do
    if String.length(string) >= max_length do
      truncated_string =
        string
        |> String.slice(0, max_length - 1)
        |> String.trim_trailing()

      truncated_string <> @ellipsis
    else
      string
    end
  end
end
