defmodule PlanepalsWeb.APIView do
  use PlanepalsWeb, :view

  def render("plane.json", %{plane: plane}) do
    plane
  end

  def render("all.json", %{planes: planes}) do
    planes
  end
end
