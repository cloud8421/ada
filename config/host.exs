use Mix.Config

config :ada, Ada.Repo, database: Path.expand("../data/#{Mix.env()}.db", __DIR__)
