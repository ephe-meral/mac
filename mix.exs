defmodule MAC.Mixfile do
  use Mix.Project

  def project do
    [app: :mac,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:mac | Mix.compilers],
     deps: deps,
     description: "MAC-to-vendor search for Elixir.",
     aliases: aliases,
     package: package]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:mac_compiler, path: "compiler"}]
  end

  defp package do
    [maintainers: ["Johanna Appel"],
     licenses: ["WTFPL"],
     files: ["db", "compiler/lib", "compiler/mix.exs", "lib", "mix.exs", "README*", "LICENSE*"],
     links: %{"GitHub" => "https://github.com/ephe-meral/mac"}]
  end

  defp aliases do
    ["clean": ["cmd rm -f db/lookup_table.eterm || true", "clean --deps"]]
  end
end
