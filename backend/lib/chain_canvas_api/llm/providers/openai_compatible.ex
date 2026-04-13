defmodule ChainCanvasApi.LLM.Providers.OpenAICompatible do
  def complete(%{
        model: model,
        system_prompt: system_prompt,
        input_texts: input_texts,
        temperature: temperature
      }) do
    api_key = System.get_env("LLM_API_KEY", "")
    base_url = String.trim_trailing(System.get_env("LLM_BASE_URL", "https://api.openai.com/v1"), "/")

    if api_key == "" do
      {:error, "LLM_API_KEY is missing"}
    else
      url = base_url <> "/chat/completions"

      messages =
        []
        |> maybe_add_system(system_prompt)
        |> Kernel.++([
          %{
            role: "user",
            content: Enum.join(input_texts, "\n\n")
          }
        ])

      case Req.post(
             url: url,
             headers: [{"authorization", "Bearer " <> api_key}],
             json: %{
               model: model,
               temperature: temperature,
               messages: messages
             },
             receive_timeout: 60_000
           ) do
        {:ok, %{status: 200, body: body}} ->
          {:ok, extract_content(body)}

        {:ok, %{status: status, body: body}} ->
          {:error, "provider error #{status}: #{inspect(body)}"}

        {:error, reason} ->
          {:error, Exception.message(reason)}
      end
    end
  end

  defp maybe_add_system(messages, nil), do: messages
  defp maybe_add_system(messages, ""), do: messages

  defp maybe_add_system(messages, system_prompt) do
    messages ++ [%{role: "system", content: system_prompt}]
  end

  defp extract_content(%{"choices" => [%{"message" => %{"content" => content}} | _]}) when is_binary(content) do
    content
  end

  defp extract_content(%{"choices" => [%{"message" => %{"content" => content}} | _]}) when is_list(content) do
    content
    |> Enum.map(fn
      %{"text" => text} -> text
      %{"type" => "text", "text" => text} -> text
      other -> inspect(other)
    end)
    |> Enum.join("")
  end

  defp extract_content(body), do: inspect(body)
end
