defmodule Ada.Source.Weather.DataPoint do
  @moduledoc false
  defstruct temperature: 0,
            apparent_temperature: 0,
            summary: "",
            icon: "",
            timestamp: 0

  @type t :: %__MODULE__{
          temperature: float,
          apparent_temperature: float,
          summary: String.t(),
          icon: String.t(),
          timestamp: DateTime.t()
        }
end
