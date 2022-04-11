defmodule Noizu.KitchenSink.Mixfile do
  use Mix.Project

  def project do
    [app: :noizu_kitchen_sink_advanced,
     version: "0.3.5",
     elixir: "~> 1.4",
     package: package(),
     deps: deps(),
     description: "Noizu Kitchen Sink Advanced",
     docs: docs(),
     elixirc_paths: elixirc_paths(Mix.env),
   ]
  end # end project

  defp package do
    [
      maintainers: ["noizu"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/noizu-labs/KitchenSinkAdvanced"}
    ]
  end # end package

  def application do
    [
      applications: [:logger],
      extra_applications: [:elixir_uuid, :fastglobal, :semaphore, :amnesia, :noizu_core, :markdown, :noizu_mnesia_versioning, :noizu_rule_engine, :timex, :sendgrid, :noizu_advanced_scaffolding, :poison]
    ]
  end # end application

  def deps do
    [
      {:ex_doc, "~> 0.16.2", only: [:dev], optional: true}, # Documentation Provider
      {:markdown, github: "devinus/markdown", optional: false}, # Markdown processor for ex_doc
      {:elixir_uuid, "~> 1.2" },
      {:exquisite, git: "https://github.com/noizu/exquisite.git", ref: "7a4a03d", override: true},
      {:amnesia, git: "https://github.com/noizu/amnesia.git", ref: "9266002", override: true}, # Mnesia Wrappeir
      {:poison, "~> 3.1.0", override: true},

      {:noizu_core, github: "noizu/ElixirCore", tag: "1.0.11", override: true},
      {:noizu_advanced_pool, git: "https://github.com/noizu-labs/SimplePoolAdvanced.git", branch: "master", override: true},
      {:noizu_advanced_scaffolding, git: "https://github.com/noizu-labs/advanced_elixir_scaffolding.git", branch: "master", override: true},

      {:noizu_mnesia_versioning, github: "noizu/MnesiaVersioning", tag: "0.1.9", override: true},
      {:noizu_rule_engine, github: "noizu/RuleEngine", tag: "0.2.0"},

      {:fastglobal, "~> 1.0"}, # https://github.com/discordapp/fastglobal
      {:semaphore, "~> 1.0"}, # https://github.com/discordapp/semaphore
      {:tzdata, github: "noizu/tzdata", tag: "opt_exp", override: true},
      {:timex, github: "noizu/timex", ref: "7e3c887", override: true},
      {:sendgrid, github: "Noizu/sendgrid_elixir", branch: "master"},
      {:mock, "~> 0.3.1", optional: true},
    ]
  end # end deps

  defp docs do
    [
      source_url_pattern: "https://github.com/noizu/KitchenSink/blob/master/%{path}#L%{line}",
      extras: ["README.md"]
    ]
  end # end docs


  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

end # end defmodule
