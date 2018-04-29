use Mix.Config

config :network, Network.Repo,
  adapter: Ecto.Adapters.MySQL,
  database: "pi2",
  username: "root",
  password: "pi2",
  hostname: "mysql"
