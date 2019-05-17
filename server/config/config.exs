# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :jinks, JinksWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FCL29/WEeuDRyTSPxC2E9XWkc1C8CrnCGwlBTl4WAtvuw0z6UbsGuX6UDsTOFMmc",
  render_errors: [view: JinksWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Jinks.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
