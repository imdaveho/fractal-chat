defmodule ChainCanvasApi.Execution.Runner do
  alias ChainCanvasApi.LLM.Provider

  def run(graph) do
    nodes = Map.get(graph, "nodes", [])
    edges = Map.get(graph, "edges", [])
    nodes_by_id = Map.new(nodes, fn node -> {node["id"], node} end)
    node_ids = MapSet.new(Map.keys(nodes_by_id))

    with :ok <- validate_edges(edges, node_ids),
         {:ok, order} <- topo_sort(nodes, edges) do
      incoming = Enum.group_by(edges, &get_in(&1, ["target", "node_id"]))

      with {:ok, outputs} <- execute_nodes(order, nodes_by_id, incoming) do
        {:ok, inject_outputs(graph, outputs)}
      end
    end
  end

  defp execute_nodes(order, nodes_by_id, incoming) do
    Enum.reduce_while(order, {:ok, %{}}, fn node_id, {:ok, outputs} ->
      node = Map.fetch!(nodes_by_id, node_id)

      input_texts =
        incoming
        |> Map.get(node_id, [])
        |> Enum.sort_by(&(&1["id"] || ""))
        |> Enum.map(fn edge -> Map.get(outputs, get_in(edge, ["source", "node_id"]), "") end)
        |> Enum.reject(&blank?/1)

      case execute_node(node, input_texts) do
        {:ok, output} ->
          {:cont, {:ok, Map.put(outputs, node_id, output)}}

        {:error, reason} ->
          {:halt, {:error, %{node_id: node_id, reason: reason}}}
      end
    end)
  end

  defp execute_node(%{"type" => "chat_input", "data" => data}, _input_texts) do
    {:ok, Map.get(data, "message", "")}
  end

  defp execute_node(%{"type" => "text_output"}, input_texts) do
    {:ok, Enum.join(input_texts, "\n\n")}
  end

  defp execute_node(%{"type" => "llm", "data" => data}, input_texts) do
    Provider.complete(%{
      provider: Map.get(data, "provider", System.get_env("LLM_PROVIDER", "mock")),
      model: Map.get(data, "model", System.get_env("LLM_MODEL", "gpt-4.1-mini")),
      system_prompt: Map.get(data, "system_prompt", ""),
      temperature: normalize_temperature(Map.get(data, "temperature", 0.2)),
      input_texts: input_texts
    })
  end

  defp execute_node(node, _input_texts) do
    {:error, "unsupported node type: #{inspect(node["type"])}"}
  end

  defp inject_outputs(graph, outputs) do
    updated_nodes =
      Enum.map(Map.get(graph, "nodes", []), fn node ->
        output = Map.get(outputs, node["id"], "")

        updated_data =
          node
          |> Map.get("data", %{})
          |> Map.put("last_output", output)
          |> maybe_put_text(node["type"], output)

        Map.put(node, "data", updated_data)
      end)

    Map.put(graph, "nodes", updated_nodes)
  end

  defp maybe_put_text(data, "text_output", output), do: Map.put(data, "text", output)
  defp maybe_put_text(data, _type, _output), do: data

  defp validate_edges(edges, node_ids) do
    case Enum.find(edges, fn edge ->
           source_id = get_in(edge, ["source", "node_id"])
           target_id = get_in(edge, ["target", "node_id"])

           not MapSet.member?(node_ids, source_id) or not MapSet.member?(node_ids, target_id)
         end) do
      nil -> :ok
      bad_edge -> {:error, %{reason: "edge references unknown node", edge: bad_edge}}
    end
  end

  defp topo_sort(nodes, edges) do
    indegree =
      Enum.reduce(nodes, %{}, fn node, acc ->
        Map.put(acc, node["id"], 0)
      end)

    indegree =
      Enum.reduce(edges, indegree, fn edge, acc ->
        target = get_in(edge, ["target", "node_id"])
        Map.update!(acc, target, &(&1 + 1))
      end)

    outgoing =
      Enum.group_by(edges, &get_in(&1, ["source", "node_id"]), &get_in(&1, ["target", "node_id"]))

    queue =
      indegree
      |> Enum.filter(fn {_id, degree} -> degree == 0 end)
      |> Enum.map(&elem(&1, 0))

    do_topo(queue, indegree, outgoing, [])
  end

  defp do_topo([], indegree, _outgoing, ordered) do
    if Enum.all?(indegree, fn {_id, degree} -> degree == 0 end) do
      {:ok, Enum.reverse(ordered)}
    else
      {:error, %{reason: "graph contains a cycle"}}
    end
  end

  defp do_topo([node_id | rest], indegree, outgoing, ordered) do
    {updated_indegree, new_ready} =
      Enum.reduce(Map.get(outgoing, node_id, []), {indegree, []}, fn target_id, {acc, ready} ->
        next_degree = Map.fetch!(acc, target_id) - 1
        acc = Map.put(acc, target_id, next_degree)

        if next_degree == 0 do
          {acc, [target_id | ready]}
        else
          {acc, ready}
        end
      end)

    do_topo(rest ++ Enum.reverse(new_ready), updated_indegree, outgoing, [node_id | ordered])
  end

  defp blank?(value), do: value in [nil, ""]

  defp normalize_temperature(value) when is_number(value), do: value * 1.0

  defp normalize_temperature(value) when is_binary(value) do
    case Float.parse(value) do
      {number, _rest} -> number
      :error -> 0.2
    end
  end

  defp normalize_temperature(_), do: 0.2
end
