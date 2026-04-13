defmodule ChainCanvasApi.GraphStore do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(graph_id) do
    Agent.get(__MODULE__, &Map.get(&1, graph_id))
  end

  def put(graph_id, graph) do
    Agent.update(__MODULE__, &Map.put(&1, graph_id, graph))
    graph
  end
end
