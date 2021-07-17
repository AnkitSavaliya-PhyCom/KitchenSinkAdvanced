defmodule Noizu.CMS.V3.Meta.RecordDefinition do

  defmacro __before_compile__(_) do
    quote do
      def __cms__(), do: %{}
      def __cms__(property), do: :pending

    end
  end

end
