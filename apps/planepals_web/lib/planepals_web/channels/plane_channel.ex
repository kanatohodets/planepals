defmodule PlanepalsWeb.PlaneChannel do
  use Phoenix.Channel

  # firehose
  def join("plane:firehose", _message, socket) do
    {:ok, socket}
  end

  def join("plane:" <> _icao, _message, socket) do
    {:ok, socket}
  end
end
