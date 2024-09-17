defmodule DesafioCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :desafio_cli,
      version: "0.1.0",
      elixir: "~> 1.16",
      escript: [main_module: DesafioCli],
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
      {:jason, "~> 1.2"},
      {:meck, "~> 0.9.0", only: :test}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
