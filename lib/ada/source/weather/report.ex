defmodule Ada.Source.Weather.Report do
  @moduledoc false

  alias Ada.Source.Weather.DataPoint

  defstruct summary: "",
            icon: "",
            location: {0, 0},
            data_points: [],
            currently: %DataPoint{}

  @type t :: %__MODULE__{
          summary: String.t(),
          icon: String.t(),
          location: {float(), float()},
          data_points: [DataPoint.t()],
          currently: DataPoint.t()
        }
end
