defmodule Noizu.V3.CMS.Meta.ArticleType.Base do

  defmacro __using__(_options \\ nil) do
    quote do

    end
  end

  defmacro __before_compile__(_) do
    quote do
      def __cms__(), do: %{}
      def __cms__(property), do: :pending

    end
  end

  def __after_compile__(_env, _bytecode) do

  end
end
