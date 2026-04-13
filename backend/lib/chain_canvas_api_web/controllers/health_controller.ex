defmodule ChainCanvasApiWeb.HealthController do
  use ChainCanvasApiWeb, :controller

  def index(conn, _params) do
    json(conn, %{ok: true})
  end
end
