defmodule MAC.Mixfile do
  use Mix.Project

  def project do
    [app: :mac,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: "MAC-to-vendor search for Elixir.",
     package: package]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp package do
    [maintainers: ["Johanna Appel"],
     licenses: ["WTFPL"],
     links: %{"GitHub" => "https://github.com/ephe-meral/ex_sider"}]
  end
end
