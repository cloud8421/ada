defmodule Ada.CLI.Format.WordWrap do
  @moduledoc false
  # Adapted from https://rosettacode.org/wiki/Word_wrap#Elixir

  def paragraph(string, max_line_length, left_pad) do
    [word | rest] = String.split(string, ~r/\s+/, trim: true)

    rest
    |> lines_assemble(max_line_length - String.length(left_pad), String.length(word), word, [])
    |> Enum.map(fn line ->
      [left_pad, line, "\n"]
    end)
  end

  defp lines_assemble([], _, _, line, acc), do: [line | acc] |> Enum.reverse()

  defp lines_assemble([word | rest], max, line_length, line, acc) do
    if line_length + 1 + String.length(word) > max do
      lines_assemble(rest, max, String.length(word), word, [line | acc])
    else
      lines_assemble(rest, max, line_length + 1 + String.length(word), line <> " " <> word, acc)
    end
  end
end
