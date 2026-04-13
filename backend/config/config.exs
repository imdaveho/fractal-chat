import Config

config :chain_canvas_api,
  ecto_repos: []

config :chain_canvas_api, ChainCanvasApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  pubsub_server: ChainCanvasApi.PubSub,
  check_origin: false,
  server: true,
  secret_key_base: "jPzY0Wf7WnS4W3q9Cw6Nf5W5v7Kp9u2Lk8d1Qm6Qh2Rr8Yt4Pz1Nv6Xa3Bc7De9F"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
