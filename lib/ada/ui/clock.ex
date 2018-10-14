defmodule Ada.UI.Clock do
  alias Ada.UI.Helpers

  def render(datetime) do
    {:static, extract_digits(datetime)}
  end

  defp extract_digits(time) do
    hour = Integer.digits(time.hour)
    minute = Integer.digits(time.minute)
    minute = Helpers.pad_with_zero(minute)
    hour = Helpers.pad_with_zero(hour)
    hour ++ minute
  end
end
