defmodule Noizu.V3.CMS.Meta.ArticleType.Versioning.Entity do

  defmodule Default do


  end

  defmacro __using__(_options \\ nil) do
    nil
  end

  def pre_defstruct(_options) do
    quote do
      @__nzdo__derive Noizu.V3.CMS.Protocol
    end
  end

  def post_defstruct(options) do
    options = Macro.expand(options, __ENV__)

    quote do
      alias Noizu.V3.CMS.Meta.ArticleType.Versioning.Entity.Default, as: Provider

      def __cms__(), do: __repo__().__cms__()
      def __cms__!(), do: __repo__().__cms__!()

      def __cms__(property), do: __repo__().__cms__(property)
      def __cms__!(property), do: __repo__().__cms__(property)

      defoverridable [
        __cms__: 0,
        __cms__!: 0,
        __cms__: 1,
        __cms__!: 1,
      ]
    end
  end

  defmacro __before_compile__(_) do
    nil
  end

  def __after_compile__(_env, _bytecode) do
    nil
  end
end
