defmodule Noizu.V3.CMS.Meta.ArticleType.Base do



  defmacro __using__(_options \\ nil) do
    nil
  end

  defmacro __before_compile__(_) do
    quote do
      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      @__nzdo__article_cms_manager Module.concat([@__nzdo__poly_base, CMS])
      def __cms_manager__(), do:  @__nzdo__article_cms_manager

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def article(ref, _context, _options) do
        Noizu.ERP.entity(ref)
      end
      def article!(ref, _context, _options) do
        Noizu.ERP.entity!(ref)
      end

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms__(), do: __cms_manager__().__cms__()
      def __cms__!(), do: __cms_manager__().__cms__!()
      def __cms__(property), do: __cms_manager__().__cms__(property)
      def __cms__!(property), do: __cms_manager__().__cms__!(property)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms_info__(ref, context, options) do
        Noizu.V3.CMS.Protocol.__cms_info__(article(ref, context, options), context, options)
      end
      def __cms_info__!(ref, context, options) do
        Noizu.V3.CMS.Protocol.__cms_info__!(article!(ref, context, options), context, options)
      end

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms_info__(ref, property, context, options) do
        Noizu.V3.CMS.Protocol.__cms_info__(article(ref, context, options), property, context, options)
      end
      def __cms_info__!(ref, property, context, options) do
        Noizu.V3.CMS.Protocol.__cms_info__!(article!(ref, context, options), property, context, options)
      end

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      defoverridable [
        __cms_manager__: 0,
        article: 3,
        article!: 3,
        __cms__: 0,
        __cms__!: 0,
        __cms__: 1,
        __cms__!: 1,
        __cms_info__: 3,
        __cms_info__!: 3,
        __cms_info__: 4,
        __cms_info__!: 4,
      ]

    end
  end

  def __after_compile__(_env, _bytecode) do
    nil
  end
end
