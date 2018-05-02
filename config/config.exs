use Mix.Config

config :network, port: 4242

config :network, :ecto_repos, [Network.Repo]

config :network, Network.Repo,
  adapter: Ecto.Adapters.MySQL,
  database: "pi2",
  username: "pi2",
  password: "pi2",
  hostname: "localhost"

# import_config "#{Mix.env}.exs"
