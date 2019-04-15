defmodule Ada.UI.Helpers do
  @moduledoc false
  @height 7
  @separator Matrix.new(@height, 1, 0)

  def pad_with_zero([a]), do: [0, a]
  def pad_with_zero(a), do: a

  def pad_with_space([a]), do: [:space, a]
  def pad_with_space(a), do: a

  def chars_to_matrix(chars) do
    center =
      chars
      |> Enum.map(&Ada.UI.Charset.char/1)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.intersperse(@separator)

    padded_left = Enum.reverse([@separator | center])
    join(padded_left, @separator)
  end

  defp join([], joined), do: joined

  defp join([current | rest], joined) do
    join(rest, :lists.zipwith(fn a, b -> a ++ b end, current, joined))
  end
end
