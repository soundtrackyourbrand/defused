defmodule Defused.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :defused,
     version: @version,
     elixir: "~> 1.4",
     package: package(),
     description: "A fuse wrapping macro for easy circuit breaking",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     docs: [source_ref: "v#{@version}",
            source_url: "https://github.com/soundtrackyourbrand/defused"]]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:fuse, "~> 2.4"},
     {:ex_doc, "~> 0.16", only: :docs},
     {:inch_ex, ">= 0.0.0", only: :docs}]
  end

  defp package do
    %{licenses: ["MIT"],
      maintainers: ["Fredrik Enestad", "Fredrik Wärnsberg"],
      links: %{"GitHub" => "https://github.com/soundtrackyourbrand/defused"}}
  end
end
