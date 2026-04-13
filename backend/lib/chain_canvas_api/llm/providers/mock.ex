defmodule ChainCanvasApi.LLM.Providers.Mock do
  def complete(%{input_texts: input_texts, system_prompt: system_prompt}) do
    body =
      input_texts
      |> Enum.reject(&(&1 in [nil, ""]))
      |> Enum.join("\n\n")

    response = """
    [mock completion]

    system:
    #{system_prompt}

    received:
    #{body}
    """

    {:ok, String.trim(response)}
  end
end
