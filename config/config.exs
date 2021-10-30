# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :wacko, WackoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SJcCYyqJQi25aGO5YJ4/LRJhb8nJwr95sFESYd6diYlKOe09azVmH1kz7xnpo3UC",
  render_errors: [view: WackoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Wacko.PubSub,
  live_view: [signing_salt: "avYSmGgO"]

config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
version: "1.39.0",
default: [
  args: ~w(css/app.scss ../priv/static/assets/app.css),
  cd: Path.expand("../assets", __DIR__)
]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
