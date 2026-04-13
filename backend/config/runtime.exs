import Config

port =
  System.get_env("PORT", "4000")
  |> String.to_integer()

host = System.get_env("PHX_HOST", "localhost")

config :chain_canvas_api, ChainCanvasApiWeb.Endpoint,
  url: [host: host, port: port],
  http: [ip: {0, 0, 0, 0}, port: port]
