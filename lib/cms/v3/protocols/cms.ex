#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.V3.CMS.Protocol do
  @fallback_to_any true

  def __cms__(ref, context, options)
  def __cms__!(ref, context, options)

  def __cms__(ref, property, context, options)
  def __cms__!(ref, property, context, options)

  def __cms_article__(ref, context, options)
  def __cms_article__!(ref, context, options)

  def __cms_article__(ref, property, context, options)
  def __cms_article__!(ref, property, context, options)
end # end defprotocol

defimpl Noizu.V3.CMS.Protocol, for: Any do
  defmacro __deriving__(module, _struct, _opts) do
    quote do
      defimpl Noizu.V3.CMS.Protocol, for: unquote(module) do
        def __cms__(_ref, _context, _options) do
          unquote(module).__cms__()
        end
        def __cms__!(_ref, _context, _options), do: unquote(module).__cms__()

        def __cms__(_ref, property, _context, _options), do: unquote(module).__cms__(property)
        def __cms__!(_ref, property, _context, _options), do: unquote(module).__cms__(property)

        def __cms_article__(ref, context, options), do: unquote(module).__cms_article__(ref, context, options)
        def __cms_article__!(ref, context, options), do: unquote(module).__cms_article__!(ref, context, options)

        def __cms_article__(ref, property, context, options), do: unquote(module).__cms_article__(ref, property, context, options)
        def __cms_article__!(ref, property, context, options), do: unquote(module).__cms_article__!(ref, property, context, options)
      end
    end
  end

  def __cms__(_ref, _context, _options), do: nil
  def __cms__!(_ref, _context, _options), do: nil

  def __cms__(_ref, _property, _context, _options), do: false
  def __cms__!(_ref, _property, _context, _options), do: false

  def __cms_article__(_ref, _context, _options), do: nil
  def __cms_article__!(_ref, _context, _options), do: nil

  def __cms_article__(_ref, _property, _context, _options), do: false
  def __cms_article__!(_ref, _property, _context, _options), do: false
end
