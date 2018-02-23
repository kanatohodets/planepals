defmodule Planepals.Cache do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def lookup(icao) do
    case :ets.lookup(__MODULE__, icao) do
      [{^icao, plane}] -> {:ok, plane}
      [] -> :error
    end
  end

  def insert(icao, plane) do
    :ets.insert(__MODULE__, {icao, plane})
  end

  def dump() do
    :ets.select(__MODULE__, [{{:'$1',:'$2'},[],[:'$2']}] )
  end

  ## Callbacks

  def init(state) do
    Process.send_after(__MODULE__, :initialize, 0)
    {:ok, state}
  end

  def handle_info(:initialize, state) do
    :ets.new(__MODULE__, [:set, :public, :named_table])
    {:noreply, state}
  end
end

