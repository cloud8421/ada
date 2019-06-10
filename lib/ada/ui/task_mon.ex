defmodule Ada.UI.TaskMon do
  @moduledoc false
  alias Ada.UI.Helpers

  @busy {:cycle,
         [
           {Helpers.chars_to_matrix([:block, :square, :dash, :space]), 50},
           {Helpers.chars_to_matrix([:square, :block, :square, :dash]), 50},
           {Helpers.chars_to_matrix([:dash, :square, :block, :square]), 50},
           {Helpers.chars_to_matrix([:square, :dash, :square, :block]), 50}
         ]}

  @finished {:static, Helpers.chars_to_matrix([:block, :block, :block, :block])}

  def render(running_tasks) do
    if MapSet.size(running_tasks) == 0, do: @finished, else: @busy
  end
end
