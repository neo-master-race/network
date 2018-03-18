defmodule Network.MixProject do
  use Mix.Project

  def project do
    [
      app: :network,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://git.unistra.fr/pi-2/network",
      homepage_url: "https://pi-2.pages.unistra.fr/network/"
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
      {:ranch, "~> 1.4"},
      {:uuid, "~> 1.1"},
      {:credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false}
    ]
  end
end
