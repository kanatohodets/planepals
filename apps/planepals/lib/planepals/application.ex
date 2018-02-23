defmodule Planepals.Application do
  @moduledoc """
  The Planepals Application Service.

  The planepals system business domain lives in this application.

  Exposes API to clients such as the `PlanepalsWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      %{
        id: Planepals.Cache,
        start: {Planepals.Cache, :start_link, []}
      },
      %{
        id: Planepals.Firehose,
        start: {Planepals.Firehose, :start_link, [%{interval: 5000}]}
      },
      %{
        id: Planepals.Feed.Opensky,
        start: {Planepals.Feed.Opensky, :start_link, [%{interval: 15000, url: "https://opensky-network.org/api/states/all"}]}
      }
    ], strategy: :one_for_one, name: Planepals.Supervisor)
  end
end
