defmodule ChainCanvasApi.Graphs do
  alias ChainCanvasApi.Execution.Runner
  alias ChainCanvasApi.GraphStore

  def get_or_create(graph_id) do
    case GraphStore.get(graph_id) do
      nil ->
        graph = default_graph(graph_id)
        GraphStore.put(graph_id, graph)

      graph ->
        graph
    end
  end

  def save_graph(graph_id, attrs) do
    graph =
      attrs
      |> normalize_graph(graph_id)
      |> GraphStore.put(graph_id)

    {:ok, graph}
  end

  def run_graph(graph_id, attrs \\ nil) do
    graph =
      case attrs do
        %{} = payload when map_size(payload) > 0 ->
          payload
          |> normalize_graph(graph_id)
          |> GraphStore.put(graph_id)

        _ ->
          get_or_create(graph_id)
      end

    with {:ok, executed} <- Runner.run(graph) do
      GraphStore.put(graph_id, executed)
      {:ok, executed}
    end
  end

  defp normalize_graph(attrs, graph_id) do
    %{
      "id" => graph_id,
      "nodes" => Enum.map(Map.get(attrs, "nodes", []), &normalize_node/1),
      "edges" => Enum.map(Map.get(attrs, "edges", []), &normalize_edge/1)
    }
  end

  defp normalize_node(node) do
    %{
      "id" => Map.get(node, "id"),
      "type" => Map.get(node, "type"),
      "position" => %{
        "x" => node |> get_in(["position", "x"]) |> normalize_number(),
        "y" => node |> get_in(["position", "y"]) |> normalize_number()
      },
      "data" => Map.get(node, "data", %{})
    }
  end

  defp normalize_edge(edge) do
    %{
      "id" => Map.get(edge, "id"),
      "source" => %{
        "node_id" => get_in(edge, ["source", "node_id"]),
        "port" => get_in(edge, ["source", "port"])
      },
      "target" => %{
        "node_id" => get_in(edge, ["target", "node_id"]),
        "port" => get_in(edge, ["target", "port"])
      }
    }
  end

  defp normalize_number(nil), do: 0.0
  defp normalize_number(number) when is_number(number), do: number * 1.0

  defp normalize_number(binary) when is_binary(binary) do
    case Float.parse(binary) do
      {number, _rest} -> number
      :error -> 0.0
    end
  end

  def default_graph(graph_id) do
    %{
      "id" => graph_id,
      "nodes" => [
        %{
          "id" => "chat-input-1",
          "type" => "chat_input",
          "position" => %{"x" => 120.0, "y" => 120.0},
          "data" => %{
            "label" => "User prompt",
            "message" => "Tell me one concise thing I should know about Phoenix and Flutter.",
            "last_output" => ""
          }
        },
        %{
          "id" => "llm-1",
          "type" => "llm",
          "position" => %{"x" => 520.0, "y" => 120.0},
          "data" => %{
            "label" => "LLM",
            "provider" => System.get_env("LLM_PROVIDER", "mock"),
            "model" => System.get_env("LLM_MODEL", "gpt-4.1-mini"),
            "system_prompt" => "You are a precise assistant. Be concise.",
            "temperature" => 0.2,
            "last_output" => ""
          }
        },
        %{
          "id" => "text-output-1",
          "type" => "text_output",
          "position" => %{"x" => 940.0, "y" => 120.0},
          "data" => %{
            "label" => "Output",
            "text" => "",
            "last_output" => ""
          }
        }
      ],
      "edges" => [
        %{
          "id" => "edge-1",
          "source" => %{"node_id" => "chat-input-1", "port" => "out"},
          "target" => %{"node_id" => "llm-1", "port" => "in"}
        },
        %{
          "id" => "edge-2",
          "source" => %{"node_id" => "llm-1", "port" => "out"},
          "target" => %{"node_id" => "text-output-1", "port" => "in"}
        }
      ]
    }
  end
end
