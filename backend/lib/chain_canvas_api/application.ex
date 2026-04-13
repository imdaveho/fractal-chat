defmodule ChainCanvasApi.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: ChainCanvasApi.PubSub},
      ChainCanvasApi.GraphStore,
      ChainCanvasApiWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: ChainCanvasApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ChainCanvasApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
