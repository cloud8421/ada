defmodule Ada.Fw.Charset do
  def char(:space),
    do: [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]

  def char(:deg),
    do: [[0, 0, 0], [1, 1, 1], [1, 0, 1], [1, 1, 1], [0, 0, 0], [0, 0, 0], [0, 0, 0]]

  def char("A"), do: [[0, 0, 0], [1, 1, 1], [1, 0, 1], [1, 1, 1], [1, 0, 1], [1, 0, 1], [0, 0, 0]]

  def char("C"), do: [[0, 0, 0], [1, 1, 1], [1, 0, 0], [1, 0, 0], [1, 0, 0], [1, 1, 1], [0, 0, 0]]

  def char("D"), do: [[0, 0, 0], [1, 1, 0], [1, 0, 1], [1, 0, 1], [1, 0, 1], [1, 1, 0], [0, 0, 0]]

  def char(1), do: [[0, 0, 0], [0, 1, 0], [1, 1, 0], [0, 1, 0], [0, 1, 0], [1, 1, 1], [0, 0, 0]]

  def char(2), do: [[0, 0, 0], [1, 1, 1], [0, 0, 1], [1, 1, 1], [1, 0, 0], [1, 1, 1], [0, 0, 0]]

  def char(3), do: [[0, 0, 0], [1, 1, 1], [0, 0, 1], [1, 1, 1], [0, 0, 1], [1, 1, 1], [0, 0, 0]]

  def char(4), do: [[0, 0, 0], [1, 0, 1], [1, 0, 1], [1, 1, 1], [0, 0, 1], [0, 0, 1], [0, 0, 0]]

  def char(5), do: [[0, 0, 0], [1, 1, 1], [1, 0, 0], [1, 1, 1], [0, 0, 1], [1, 1, 1], [0, 0, 0]]

  def char(6), do: [[0, 0, 0], [1, 1, 1], [1, 0, 0], [1, 1, 1], [1, 0, 1], [1, 1, 1], [0, 0, 0]]

  def char(7), do: [[0, 0, 0], [1, 1, 1], [0, 0, 1], [0, 0, 1], [0, 0, 1], [0, 0, 1], [0, 0, 0]]

  def char(8), do: [[0, 0, 0], [1, 1, 1], [1, 0, 1], [1, 1, 1], [1, 0, 1], [1, 1, 1], [0, 0, 0]]

  def char(9), do: [[0, 0, 0], [1, 1, 1], [1, 0, 1], [1, 1, 1], [0, 0, 1], [0, 0, 1], [0, 0, 0]]

  def char(0), do: [[0, 0, 0], [1, 1, 1], [1, 0, 1], [1, 0, 1], [1, 0, 1], [1, 1, 1], [0, 0, 0]]
end
