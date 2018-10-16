defmodule Ada.UI.Clock do
  alias Ada.UI.Helpers

  def render(datetime) do
    content =
      datetime
      |> extract_digits
      |> Helpers.chars_to_matrix()

    {:static, content}
  end

  defp extract_digits(time) do
    hour = Integer.digits(time.hour)
    minute = Integer.digits(time.minute)
    minute = Helpers.pad_with_zero(minute)
    hour = Helpers.pad_with_zero(hour)
    hour ++ minute
  end
end
