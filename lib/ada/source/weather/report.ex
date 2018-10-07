defmodule Ada.Source.Weather.Report do
  defstruct summary: "",
            icon: "",
            location: {0, 0},
            data_points: [],
            currently: %{}
end
