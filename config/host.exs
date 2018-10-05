use Mix.Config

config :logger, backends: [:console]

config :ada, Ada.Repo, database: Path.expand("../data/#{Mix.env()}.db", __DIR__)
