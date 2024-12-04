defmodule BillingCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :billing_core,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}

      {:ecto_sql, "~> 3.12.1"},
      {:xml_builder, "~> 2.3.0"},
      {:httpoison, "~> 2.2.1"},
      {:mox, "~> 1.2.0", only: :test},
      {:timex, "~> 3.7.11"},
      {:xmerl_c14n, "~> 0.2.0"},
      {:sweet_xml, "~> 0.7.4"},
      {:mock, "~> 0.3.8", only: :test},
      {:mimic, "~> 1.10.2", only: :test},
      {:hackney, "~> 1.20.1"},
      {:poison, "~> 6.0.0"},
      {:easy_ssl, github: "CaliDog/EasySSL", branch: "master"},
      {:sobelow, "~> 0.13.0", only: [:dev, :test], runtime: false}
    ]
  end
end
