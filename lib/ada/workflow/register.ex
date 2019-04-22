defmodule Ada.Workflow.Register do
  @moduledoc false
  @own_name Module.split(__MODULE__)

  alias Ada.Workflow

  @spec all :: [Workflow.t()]
  def all do
    {:ok, app_modules} = :application.get_key(:ada, :modules)
    Enum.filter(app_modules, &is_workflow_module?/1)
  end

  @spec with_requirements :: %{Workflow.t() => Workflow.requirements()}
  def with_requirements do
    Enum.reduce(all(), %{}, fn name, acc ->
      Map.put(acc, name, name.requirements())
    end)
  end

  defp is_workflow_module?(app_module) do
    case Module.split(app_module) do
      @own_name -> false
      ["Ada", "Workflow", _workflow_name] -> true
      _other -> false
    end
  end
end
