defmodule Ada.Source.Weather.DataPoint do
  @moduledoc false
  defstruct temperature: 0,
            apparent_temperature: 0,
            summary: "",
            icon: "",
            timestamp: 0
end
