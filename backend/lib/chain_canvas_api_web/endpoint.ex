defmodule ChainCanvasApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chain_canvas_api

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug ChainCanvasApiWeb.Plugs.CORS

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug ChainCanvasApiWeb.Router
end
