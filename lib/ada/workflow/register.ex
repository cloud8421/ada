defmodule Ada.Workflow.Register do
  def names do
    {:ok, app_modules} = :application.get_key(:ada, :modules)
    Enum.filter(app_modules, &is_workflow_module?/1)
  end

  def names_and_requirements do
    Enum.reduce(names(), %{}, fn name, acc ->
      Map.put(acc, name, name.requirements())
    end)
  end

  defp is_workflow_module?(app_module) do
    case Module.split(app_module) do
      ["Ada", "Workflow", "Register"] -> false
      ["Ada", "Workflow", _workflow_name] -> true
      _other -> false
    end
  end
end
