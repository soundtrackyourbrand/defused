defmodule Defused.Mixfile do
  use Mix.Project

  def project do
    [app: :defused,
     version: "0.1.0",
     elixir: "~> 1.4",
     package: package(),
     description: "A fuse wrapping macro for easy circuit breaking",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:fuse, "~> 2.4"}]
  end

  defp package do
    %{licenses: ["MIT"],
      maintainers: ["Fredrik Enestad", "Fredrik Wärnsberg"],
      links: %{"GitHub" => "https://github.com/soundtrackyourbrand/defused"}}
  end
end
