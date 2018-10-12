use Mix.Config

if Mix.env() == :test do
  config :logger, level: :error, backends: []
else
  config :logger, backends: [:console]
end

config :ada, Ada.Repo, database: Path.expand("../data/#{Mix.env()}.db", __DIR__)
