defmodule PlanepalsWeb.Router do
  use PlanepalsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PlanepalsWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", PlanepalsWeb do
    pipe_through :api 
    get "/plane", APIController, :index
  end


  # Other scopes may use custom stacks.
  # scope "/api", PlanepalsWeb do
  #   pipe_through :api
  # end
end
