defmodule Ada.MixProject do
  use Mix.Project

  @all_targets [:rpi0]

  def project do
    [
      app: :ada,
      version: "0.1.0",
      elixir: "~> 1.8",
      archives: [nerves_bootstrap: "~> 1.5"],
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.target() != :host,
      deps_path: "deps/#{Mix.target()}",
      aliases: [
        loadconfig: [&bootstrap/1],
        "ecto.reset": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate --quiet"]
      ],
      deps: deps(),
      escript: [
        main_module: Ada.CLI,
        app: nil
      ],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Ada.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets, :ssl],
      included_applications: [:vmstats]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.5"},
      {:sqlite_ecto2, "~> 2.2"},
      {:jason, "~> 1.1"},
      {:calendar, "~> 0.17.4"},
      {:matrix, "~> 0.3.2"},
      {:nerves, "~> 1.3", runtime: false},
      {:shoehorn, "~> 0.4"},
      {:ring_logger, "~> 0.4"},
      {:toolshed, "~> 0.2"},
      {:ex_cli, "~> 0.1.6"},
      {:floki, "~> 0.21.0"},
      {:vmstats, "~> 2.3"},
      {:telemetry, "~> 0.4.0"},
      {:statix, "~> 1.1"},
      {:junit_formatter, "~> 3.0", only: :test},
      {:ex_doc, "~> 0.20.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_init_gadget, "~> 0.4", targets: @all_targets},
      {:nerves_time, "~> 0.2.0", targets: @all_targets},
      {:elixir_ale, "~> 1.1", targets: @all_targets},
      {:power_control, "~> 0.2.0", targets: :rpi0},
      {:nerves_system_rpi0, "~> 1.0", runtime: false, targets: :rpi0}
    ]
  end
end
