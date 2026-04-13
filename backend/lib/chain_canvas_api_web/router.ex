defmodule ChainCanvasApiWeb.Router do
  use ChainCanvasApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ChainCanvasApiWeb do
    pipe_through :api

    get "/health", HealthController, :index
    get "/graphs/:id", GraphController, :show
    put "/graphs/:id", GraphController, :upsert
    post "/graphs/:id/run", GraphController, :run
  end
end
