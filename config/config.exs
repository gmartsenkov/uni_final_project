# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :uni,
  ecto_repos: [Uni.Repo]

# Configures the endpoint
config :uni, UniWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pmL98CL7cjhJIwYLe+GwluR6cU1IS5OBnsRngS6J7HP0lnr1c3qf8i2GIfVULbfj",
  render_errors: [view: UniWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Uni.PubSub,
  live_view: [signing_salt: "LD7tKVkx"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
