defmodule Echo.MixProject do
  use Mix.Project

  def project do
    [
      app: :echo,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Echo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.6"},
      {:plug, "~> 1.14"},
      {:jason, "~> 1.4"},
      {:joken, "~> 2.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:bcrypt_elixir, "~> 3.0"}
    ]
  end
end
