defmodule PlanepalsWeb.APIController do
  use PlanepalsWeb, :controller

  def index(conn, %{"icao" => "all"}=_params) do
    render conn, "all.json", planes: Planepals.Cache.dump()
  end

  def index(conn, %{"icao" => icao}=_params) do
    case Planepals.Cache.lookup(icao) do
      {:ok, plane} -> render conn, "plane.json", plane: plane
      :error -> 
        conn 
          |> put_status(:not_found)
          |> render(PlanepalsWeb.ErrorView, :"404") 
          |> halt()
    end
  end

  def index(conn, _params) do
    conn 
      |> put_status(:bad_request)
      |> render(PlanepalsWeb.ErrorView, :"400") 
      |> halt()
  end
end
