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

  def post_defstruct(_options) do
    #options = Macro.expand(options, __ENV__)
    quote do
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"

      alias Noizu.V3.CMS.Meta.ArticleType.Versioning.Entity.Default, as: Provider

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __cms__(), do: __repo__().__cms__()

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __cms__!(), do: __repo__().__cms__!()

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __cms__(property), do: __repo__().__cms__(property)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
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
