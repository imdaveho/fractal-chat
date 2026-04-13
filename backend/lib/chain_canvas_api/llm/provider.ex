defmodule ChainCanvasApi.LLM.Provider do
  alias ChainCanvasApi.LLM.Providers.Mock
  alias ChainCanvasApi.LLM.Providers.OpenAICompatible

  def complete(%{provider: provider} = params) when provider in ["mock", nil] do
    Mock.complete(params)
  end

  def complete(%{provider: provider} = params) when provider in ["openai", "openai_compatible"] do
    OpenAICompatible.complete(params)
  end

  def complete(%{} = params) do
    case System.get_env("LLM_PROVIDER", "mock") do
      "mock" -> Mock.complete(params)
      _ -> OpenAICompatible.complete(params)
    end
  end
end
