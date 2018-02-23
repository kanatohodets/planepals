defmodule Planepals.Feed.Opensky do
  use GenServer
  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ## Callbacks

  def init(state) do
    Process.send_after(__MODULE__, :fetch, 0)
    {:ok, state}
  end

  def handle_info(:fetch, %{url: url, interval: delay}=state) do
    Logger.info("time to fetch #{url}")
    {:ok, 
      %HTTPoison.Response{status_code: 200, body: body}
    } = HTTPoison.get(url)

    %{"states" => planes} = Jason.decode! body

    planes
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.filter(&filter/1)
    |> Flow.each(&cache/1)
    |> Flow.run()

    Process.send_after(self(), :fetch, delay)
    {:noreply, state}
  end

  defp filter([icao, _callsign, country, _, _, long, lat | _rest]) do
    icao != nil && 
      country != nil && 
        lat != nil && long != nil
  end

  defp cache([icao, callsign, country, _, _, long, lat | _rest]=plane) do
    trimmed = %{icao: icao, callsign: String.trim(callsign), country: country, lat: lat, long: long}
    Planepals.Cache.insert(icao, trimmed)
    PlanepalsWeb.Endpoint.broadcast("plane:" <> icao , "plane", trimmed)
  end
end
