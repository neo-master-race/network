defmodule Network.MixProject do
  use Mix.Project

  def project do
    [
      app: :network,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      applications: [:exprotobuf, :ranch],
      extra_applications: [:logger],
      mod: {Network.Application, []}
    ]
  end

  defp deps do
    [
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.18.3", only: :dev},
      {:exprotobuf, "~> 1.2"},
      {:ranch, "~> 1.4"}
    ]
  end
end
