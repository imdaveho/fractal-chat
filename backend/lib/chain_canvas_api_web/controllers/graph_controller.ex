defmodule ChainCanvasApiWeb.GraphController do
  use ChainCanvasApiWeb, :controller

  alias ChainCanvasApi.Graphs

  def show(conn, %{"id" => id}) do
    json(conn, Graphs.get_or_create(id))
  end

  def upsert(conn, %{"id" => id} = params) do
    attrs = Map.drop(params, ["id"])

    case Graphs.save_graph(id, attrs) do
      {:ok, graph} ->
        json(conn, graph)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def run(conn, %{"id" => id} = params) do
    attrs =
      params
      |> Map.drop(["id"])
      |> empty_to_nil()

    case Graphs.run_graph(id, attrs) do
      {:ok, graph} ->
        json(conn, graph)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  defp empty_to_nil(map) when map_size(map) == 0, do: nil
  defp empty_to_nil(map), do: map
end
