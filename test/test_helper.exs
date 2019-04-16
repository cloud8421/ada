if System.get_env("CI") do
  ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])
else
  ExUnit.configure(formatters: [ExUnit.CLIFormatter])
end

ExUnit.start()
