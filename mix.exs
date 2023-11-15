defmodule UeberauthXero.MixProject do
  use Mix.Project

  @source_url "https://github.com/msmithstubbs/ueberauth_xero"
  @version "0.1.0"

  def project do
    [
      app: :ueberauth_xero,
      version: @version,
      name: "Üeberauth Xero",
      elixir: "~> 1.13",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :oauth2, :ueberauth]
    ]
  end

  defp deps do
    [
      {:oauth2, "~> 1.0 or ~> 2.0"},
      {:ueberauth, "~> 0.10.0"},
      {:jose, "~> 1.11.0"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      description: "An Uberauth strategy for Xero OAuth2 authentication.",
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Matt Stubbs"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url
      }
    ]
  end
end
