defmodule RabbitHole.Mixfile do
  use Mix.Project

  def project do
    [app: :rabbit_hole,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package(),
     name: "RabbitHole"]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :amqp]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:amqp, "~> 0.1"},
     {:amqp_client, git: "https://github.com/jbrisbin/amqp_client.git", override: true},
     {:gen_stage, "~> 0.9"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:credo, "~> 0.4", only: [:dev, :test]}]
  end

  defp description do
    """
    A simplified interface for RPC over RabbitMQ.
    """
  end

  defp package do
    [maintainers: ["Ray Cheung"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/raycheung/rabbit_hole"}]
  end
end
