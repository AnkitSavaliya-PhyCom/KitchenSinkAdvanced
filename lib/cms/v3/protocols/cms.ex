#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.V3.CMS.Protocol do
  @fallback_to_any true

  def __cms__(ref, context, options)
  def __cms__!(ref, context, options)

end # end defprotocol



defimpl Noizu.V3.CMS.Protocol, for: Any do
  defmacro __deriving__(module, _struct, _opts) do
    quote do
      defimpl Noizu.V3.CMS.Protocol, for: unquote(module) do
        def __cms__(_ref, _context, _options), do: true
        def __cms__!(_ref, _context, _options), do: true
      end
    end
  end

  def __cms__(_ref, _context, _options), do: false
  def __cms__!(_ref, _context, _options), do: false
end

