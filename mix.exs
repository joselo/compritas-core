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
      {:ecto_sql, "~> 3.12.1"},
      {:xml_builder, "~> 2.3.0"},
      {:httpoison, "~> 2.2.1"},
      {:timex, "~> 3.7.11"},
      {:xmerl_c14n, "~> 0.2.0"},
      {:sweet_xml, "~> 0.7.4"},
      {:mimic, "~> 1.10.2", only: :test},
      {:poison, "~> 6.0.0"},
      {:elixir_xml_to_map, "~> 3.1.0"},
      {:pdf, "~> 0.7.1"},
      {:easy_ssl, github: "CaliDog/EasySSL", branch: "master"}
    ]
  end
end
