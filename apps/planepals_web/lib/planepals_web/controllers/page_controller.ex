defmodule PlanepalsWeb.PageController do
  use PlanepalsWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
