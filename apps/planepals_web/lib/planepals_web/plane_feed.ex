defmodule PlanepalsWeb.PlaneFeed do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(args) do
	{:ok, args}
  end

  # allow the domain to push updates in a loosely coupled way (GenServer.cast
  # will silently fail if the process is not available to receive it)
  def handle_cast({:plane, [topic: topic, payload: payload]}, state) do
    PlanepalsWeb.Endpoint.broadcast(topic, "plane", payload)
    {:noreply, state}
  end
end
