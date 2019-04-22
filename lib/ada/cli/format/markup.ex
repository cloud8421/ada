defmodule Ada.CLI.Markup do
  @moduledoc """
  This module defines semantic helpers that can be used to format
  CLI-based reports.

  It includes (among other things) titles, headings, paragraphs (with support
  for wrapping text), lists and bars.

  The recommended usage pattern is to build lists of elements and then
  pass them to `IO.iodata_to_binary/1` for conversion to a printable binary.
  """

  @bar_item "█"
  @break "\n"
  @dash "-"
  @ellipsis "…"
  @emdash "—"
  @left_pad "  "
  @space " "

  alias IO.ANSI
  alias Ada.CLI.Format.WordWrap

  @doc "New line separator"
  def break, do: @break

  @doc "Space separator"
  def space, do: @space

  @doc "Left padding"
  def left_pad, do: @left_pad

  @doc """
  Returns the text padded on the left, in red color
  and adds a break at the end.
  """
  def title(contents) do
    [@left_pad, ANSI.format([:red, contents], true), @break]
  end

  @doc """
  Separates left text and right text with a continuous line, pushing them
  to the left and right border of the page. The left text is wrapped in red.

  E.g. `Left ———————————————————————————————— Right`
  """
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

  @doc """
  Returns the text wrappend on the left, in primary color
  and adds a break at the end.
  """
  def h1(contents) do
    [@left_pad, primary(contents), @break]
  end

  @doc """
  Returns the text wrappend on the left, in secondary color
  and adds a break at the end.
  """
  def h2(contents) do
    [@left_pad, secondary(contents), @break]
  end

  @doc """
  Returns the text wrappend on the left, in tertiary color
  and adds a break at the end.
  """
  def h3(contents) do
    [@left_pad, tertiary(contents), @break]
  end

  @doc """
  Returns the text, wrapped at the specified length.

  All lines are padded on the left and it adds a break at the end.
  """
  def p(contents, max_length) do
    [WordWrap.paragraph(contents, max_length, @left_pad), @break]
  end

  @doc """
  Returns a list item, i.e. a definition with a name (wrapped in secondary
  colour) and a value.

  Values are pretty printed according to their type:

  - maps, keyword lists and lists of tuples get expanded one pair per line, with the pair elements
  separated by a :
  - lists get expanded one element per line
  - other values are printed on one line beside the name.
  """
  def list_item(name, values) when is_list(values) do
    [
      h2(name <> ":"),
      Enum.map(values, fn
        {k, v} ->
          [@left_pad, @left_pad, "- #{k}: #{v}", @break]

        v ->
          [@left_pad, @left_pad, "- #{v}", @break]
      end)
    ]
  end

  def list_item(name, value) do
    [@left_pad, secondary(name <> ":"), @space, value, @break]
  end

  @doc "Wraps contents in primary color"
  def primary(contents) do
    ANSI.format([:cyan, contents], true)
  end

  @doc "Wraps contents in secondary color"
  def secondary(contents) do
    ANSI.format([:yellow, contents], true)
  end

  @doc "Wraps contents in tertiary color"
  def tertiary(contents) do
    ANSI.format([:green, contents], true)
  end

  @doc "Returns an emphasis dash, wrapped in spaces"
  def emdash do
    [
      @space,
      @emdash,
      @space
    ]
  end

  @doc "Returns a dash, followed by a space"
  def dash do
    [
      @dash,
      @space
    ]
  end

  @doc "Returns a bar of the specified length."
  def bar(length) do
    String.duplicate(@bar_item, length)
  end

  @doc "Truncates the text at the specified length, appending an ellipsis"
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
