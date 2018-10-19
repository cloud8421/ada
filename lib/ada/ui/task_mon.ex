defmodule Ada.UI.TaskMon do
  alias Ada.UI.Helpers

  def render(running_tasks) do
    content =
      running_tasks
      |> running_count
      |> Helpers.chars_to_matrix()

    {:static, content}
  end

  defp running_count(running_tasks) do
    padded_count =
      running_tasks
      |> MapSet.size()
      |> Integer.digits()
      |> Helpers.pad_with_space()

    'RT' ++ padded_count
  end
end
