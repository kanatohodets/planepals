defmodule Planepals.Feed.Opensky do
  use GenServer
  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ## Callbacks

  def init(params) do
    Process.send_after(__MODULE__, :fetch, 0)
    state = params
    {:ok, state}
  end

  def handle_info(:fetch, %{url: url, interval: interval}=state) do
    options =
      case Application.get_env(:planepals, :proxy, nil) do
        nil -> []
        proxy -> [proxy: proxy]
      end

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url, [], options),
         {:ok, %{"states" => planes}} <- Jason.decode(body)
    do
      {:ok, process_update(planes)}
    else
      error -> handle_error(error)
    end

    # in either outcome we'll update again in $interval
    Process.send_after(self(), :fetch, interval)
    {:noreply, state}
  end

  defp handle_error({_, %HTTPoison.Response{}=res}), do:
    Logger.warn("API returned non-200: #{inspect res}")

  defp handle_error({:error, %HTTPoison.Error{}=err}), do:
    Logger.warn("HTTPoison error: #{inspect err}")

  defp handle_error({:error, %Jason.DecodeError{}=err}), do:
    Logger.warn("JSON decoding error #{inspect err}")

  defp handle_error(error), do:
    Logger.warn("unknown error: #{inspect error}")

  defp process_update(planes) do
    planes
      |> Flow.from_enumerable()
      |> Flow.partition()
      |> Flow.filter(&filter/1)
      |> Flow.each(&cache_and_broadcast/1)
      |> Flow.run()
  end

  defp filter([icao, _callsign, country, _, _, long, lat | _rest]) do
    icao != nil &&
      country != nil &&
        lat != nil && long != nil
  end

  defp cache_and_broadcast([icao, callsign, country, _, _, long, lat | _rest]=_plane) do
    trimmed = %{icao: icao, callsign: String.trim(callsign), country: country, lat: lat, long: long}
    Planepals.Cache.insert(icao, trimmed)
    GenServer.cast(PlanepalsWeb.PlaneFeed, {:plane, [topic: "plane:" <> icao, payload: trimmed]})
  end
end
