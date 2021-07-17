defmodule Noizu.CMS.V3.Meta.RecordDefinition.ArticleRepo do

  defmacro __before_compile__(_) do
    quote do
      def __cms__(), do: @__nzdo__base.__cms__()
      def __cms__(property), do: @__nzdo__base.__cms__(property)

    end
  end

end
