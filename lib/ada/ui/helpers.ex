defmodule Ada.UI.Helpers do
  def pad_with_zero([a]), do: [0, a]
  def pad_with_zero(a), do: a
end
