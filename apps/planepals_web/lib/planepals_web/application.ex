defmodule PlanepalsWeb.Application do
  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link([
      {PlanepalsWeb.Endpoint, []},
      {PlanepalsWeb.PlaneFeed, []},
    ], strategy: :one_for_one, name: PlanepalsWeb.Supervisor)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PlanepalsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
