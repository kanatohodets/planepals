defmodule Planepals.Firehose do
  use GenServer
  require Logger

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end

  ## Callbacks

  def init(%{interval: delay}=params) do
    Process.send_after(__MODULE__, :pump, delay)
    {:ok, params}
  end

  def handle_info(:pump, %{interval: delay}=state) do
    PlanepalsWeb.Endpoint.broadcast("plane:firehose", "plane", %{"planes" => Planepals.Cache.dump()})
    Process.send_after(self(), :pump, delay)
    {:noreply, state}
  end
end
