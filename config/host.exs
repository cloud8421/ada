use Mix.Config

config :ada, http_port: 4000

if Mix.env() == :test do
  config :logger, level: :error, backends: []
else
  config :logger, backends: [:console]
end

config :tzdata, :data_dir, Path.expand("../data/#{Mix.env()}/tz_data", __DIR__)

config :ada, Ada.Repo, database: Path.expand("../data/#{Mix.env()}.db", __DIR__)
