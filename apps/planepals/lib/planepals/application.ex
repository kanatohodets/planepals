defmodule Planepals.Application do
  @moduledoc """
  The Planepals Application Service.

  The planepals system business domain lives in this application.

  Exposes API to clients such as the `PlanepalsWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link([
      { Planepals.Cache, []},
      { Planepals.Firehose, %{interval: 5000}},
      { Planepals.Feed.Opensky, %{interval: 15000, url: "https://opensky-network.org/api/states/all"}},
    ], strategy: :one_for_one, name: Planepals.Supervisor)
  end
end
