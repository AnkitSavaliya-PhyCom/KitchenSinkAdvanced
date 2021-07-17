defmodule Noizu.V3.CMS.Meta.ArticleType.Entity do

  defmacro __using__(_options \\ nil) do
    quote do
      @__nzdo__derive Noizu.V3.CMS.Protocol
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def __cms__(), do: @__nzdo__base.__cms__()
      def __cms__(property), do: @__nzdo__base.__cms__(property)
    end
  end

  def __after_compile__(_env, _bytecode) do

  end
end
