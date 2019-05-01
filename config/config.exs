# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :ecto, json_library: Jason

config :ada,
  ecto_repos: [Ada.Repo]

config :ada, Ada.Repo, adapter: Sqlite.Ecto2

config :ada, :default_preferences, timezone: "Europe/London"

get_env_int = fn var ->
  case System.get_env(var) do
    nil -> nil
    string -> String.to_integer(string)
  end
end

get_env_charlist = fn var ->
  case System.get_env(var) do
    nil -> nil
    string -> String.to_charlist(string)
  end
end

config :statix,
  host: System.get_env("STATSD_HOST") || "127.0.0.1",
  port: get_env_int.("STATSD_PORT") || 8125

config :logger, Logger.Backends.Telegraf,
  level: :info,
  facility: :local1,
  appid: "ada",
  format: "$message",
  metadata: :all,
  host: get_env_charlist.("SYSLOG_HOST") || '127.0.0.1',
  port: get_env_int.("SYSLOG_PORT") || 6514

if Mix.env() == :test do
  config :junit_formatter,
    report_file: "junit-report.xml",
    report_dir: "test/mix",
    print_report_file: true,
    prepend_project_name?: true
end

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

import_config "#{Mix.target()}.exs"
