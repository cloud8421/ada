if System.get_env("CI") do
  ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])
else
  ExUnit.configure(formatters: [ExUnit.CLIFormatter])
end

Code.require_file(Path.expand("support/test_workflow.ex", __DIR__))

ExUnit.start()
