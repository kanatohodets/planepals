# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :planepals_web,
  namespace: PlanepalsWeb

# Configures the endpoint
config :planepals_web, PlanepalsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1zEEctJXq03zCc6VSq/QDA8/RbQV9qE8N0ibKAPfE20WlR4thqKRvq68COmb5E/U",
  render_errors: [view: PlanepalsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PlanepalsWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :planepals_web, :generators,
  context_app: :planepals

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
