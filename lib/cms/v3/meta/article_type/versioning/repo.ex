defmodule Noizu.V3.CMS.Meta.ArticleType.Versioning.Repo do

  defmacro __using__(_options \\ nil) do

  end

  def pre_defstruct(_options) do
    quote do

    end
  end

  def post_defstruct(_options) do
    quote do
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"

      #-----------------------------------------
      #
      #-----------------------------------------
      def __cms__(), do: nil
      def __cms__!(), do: nil

      #-----------------------------------------
      #
      #-----------------------------------------
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

  defmacro __before_compile__(_) do
    quote do

    end
  end

  def __after_compile__(_env, _bytecode) do
    nil
  end
end
