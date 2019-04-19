defmodule Ada.CLI.Markup do
  @bar_item "█"
  @break "\n"
  @dash "-"
  @ellipsis "…"
  @emdash "—"
  @left_pad "  "
  @space " "

  alias IO.ANSI
  alias Ada.CLI.Format.WordWrap

  def break, do: @break

  def space, do: @space

  def left_pad, do: @left_pad

  def title(contents) do
    [@left_pad, ANSI.format([:red, contents], true), @break]
  end

  def double_title(left, right, max_length) do
    separator_length = max_length - String.length(left) - String.length(right) - 2

    [
      @left_pad,
      ANSI.format([:red, left], true),
      @space,
      String.duplicate(@emdash, separator_length),
      @space,
      right,
      @break
    ]
  end

  def h1(contents) do
    [@left_pad, primary(contents), @break]
  end

  def h2(contents) do
    [@left_pad, secondary(contents), @break]
  end

  def h3(contents) do
    [@left_pad, tertiary(contents), @break]
  end

  def p(contents, max_length) do
    [WordWrap.paragraph(contents, max_length, @left_pad), @break]
  end

  def primary(contents) do
    ANSI.format([:cyan, contents], true)
  end

  def secondary(contents) do
    ANSI.format([:yellow, contents], true)
  end

  def tertiary(contents) do
    ANSI.format([:green, contents], true)
  end

  def emdash do
    [
      @space,
      @emdash,
      @space
    ]
  end

  def dash do
    [
      @dash,
      @space
    ]
  end

  def bar(length) do
    String.duplicate(@bar_item, length)
  end

  def ellipsis(string, max_length) do
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
