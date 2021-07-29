defmodule Noizu.V3.CMS.Meta.ArticleType.Versioning.Base do



  defmacro __using__(_options \\ nil) do
    nil
  end

  defmacro __before_compile__(_) do
    quote do
      def __cms__(), do: nil
      def __cms__!(), do: nil
      def __cms__(property), do: nil
      def __cms__!(property), do: nil



      defoverridable [
        __cms__: 0,
        __cms__!: 0,
        __cms__: 1,
        __cms__!: 1,
      ]

    end
  end

  def __after_compile__(_env, _bytecode) do
    nil
  end
end
