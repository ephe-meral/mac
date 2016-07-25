defmodule MAC.Mixfile do
  use Mix.Project

  def project do
    [app: :mac,
     version: "0.2.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "MAC-to-vendor search for Elixir.",
     package: package]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    [maintainers: ["Johanna Appel"],
     licenses: ["WTFPL"],
     files: ["priv", "lib", "mix.exs", "README*", "LICENSE*"],
     links: %{"GitHub" => "https://github.com/ephe-meral/mac"}]
  end
end
