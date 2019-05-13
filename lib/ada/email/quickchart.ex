defmodule Ada.Email.Quickchart do
  @moduledoc """
  Minimal DSL and functions to create image charts
  via https://quickchart.io.

  Doesn't support all api options (yet).
  """

  @default_width 516
  @default_height 300
  @base_url "https://quickchart.io/chart"

  defstruct type: "bar",
            width: @default_width,
            height: @default_height,
            data: %{labels: [], datasets: []}

  @type chart_type :: String.t()
  @type label :: String.t()
  @type dimension :: pos_integer()
  @type data :: [number()]
  @type dataset :: %{label: label(), data: data()}

  @type t :: %__MODULE__{
          type: chart_type(),
          width: dimension(),
          height: dimension(),
          data: %{labels: [label()], datasets: [dataset()]}
        }

  @doc """
  Given a chart type, return a new chart. Defaults to bar

      iex> Ada.Email.Quickchart.new()
      %Ada.Email.Quickchart{
        data: %{datasets: [], labels: []},
        height: 300,
        type: "bar",
        width: 516
      }
      iex> Ada.Email.Quickchart.new("line")
      %Ada.Email.Quickchart{
        data: %{datasets: [], labels: []},
        height: 300,
        type: "line",
        width: 516
      }
  """
  @spec new(chart_type()) :: t()
  def new(type \\ "bar"), do: %__MODULE__{type: type}

  @doc """
  Given a chart, set its dimensions.
      iex> Ada.Email.Quickchart.new()
      ...> |> Ada.Email.Quickchart.set_dimensions(200, 200)
      %Ada.Email.Quickchart{
        data: %{datasets: [], labels: []},
        height: 200,
        type: "bar",
        width: 200
      }
  """
  @spec set_dimensions(t(), dimension(), dimension()) :: t()
  def set_dimensions(chart, width, height) do
    %{chart | width: width, height: height}
  end

  @doc """
  Given a chart, add general labels.

      iex> Ada.Email.Quickchart.new()
      ...> |> Ada.Email.Quickchart.add_labels(["May", "June"])
      %Ada.Email.Quickchart{
        data: %{datasets: [], labels: ["May", "June"]},
        height: 300,
        type: "bar",
        width: 516
      }
  """
  @spec add_labels(t(), [label()]) :: t()
  def add_labels(chart, labels) do
    %{chart | data: Map.put(chart.data, :labels, labels)}
  end

  @doc """
  Given a chart, add a new dataset, identified by its label and data.

      iex> Ada.Email.Quickchart.new()
      ...> |> Ada.Email.Quickchart.add_dataset("Sales", [1,2,3])
      %Ada.Email.Quickchart{
        data: %{datasets: [%{label: "Sales", data: [1,2,3]}], labels: []},
        height: 300,
        type: "bar",
        width: 516
      }
  """
  @spec add_dataset(t(), label(), data()) :: t()
  def add_dataset(chart, label, data) do
    dataset = %{label: label, data: data}
    %{chart | data: Map.update!(chart.data, :datasets, fn current -> current ++ [dataset] end)}
  end

  @doc """
  Given a chart, returns its corresponding quickchart url.

      iex> Ada.Email.Quickchart.new()
      ...> |> Ada.Email.Quickchart.add_labels(["April", "May", "June"])
      ...> |> Ada.Email.Quickchart.add_dataset("Sales", [1,2,3])
      ...> |> Ada.Email.Quickchart.to_url()
      "https://quickchart.io/chart?c=%7B%27data%27%3A%7B%27datasets%27%3A%5B%7B%27data%27%3A%5B1%2C2%2C3%5D%2C%27label%27%3A%27Sales%27%7D%5D%2C%27labels%27%3A%5B%27April%27%2C%27May%27%2C%27June%27%5D%7D%2C%27type%27%3A%27bar%27%7D&height=300&width=516"
  """
  @spec to_url(t()) :: String.t()
  def to_url(chart) do
    payload = Map.take(chart, [:type, :data])

    qs = %{
      width: chart.width,
      height: chart.height,
      c: payload |> Jason.encode!() |> String.replace(~s("), "'")
    }

    @base_url <> "?" <> URI.encode_query(qs)
  end
end
