defmodule Noizu.V3.CMS.Meta.ArticleType.Base do



  defmacro __using__(_options \\ nil) do
    nil
  end

  defmacro __before_compile__(_) do
    quote do
      @__nzdo__article_cms_manager Module.concat([@__nzdo__poly_base, CMS])
      def __cms_manager__(), do:  @__nzdo__article_cms_manager

      def __article__(ref, _context, _options) do
        # todo handle sref, ref, etc.
        Noizu.ERP.entity(ref)
      end
      def __article__!(ref, _context, _options) do
        # todo handle sref, ref, etc.
        Noizu.ERP.entity!(ref)
      end

      if @__nzdo__poly_base == __MODULE__ do
        def __cms__(), do: __MODULE__
        def __cms__(property), do: {__MODULE__, property}
      else
        def __cms__(), do: @__nzdo__poly_base.__cms__()
        def __cms__(property), do: @__nzdo__poly_base.__cms__(property)
      end



      def __cms_article__(ref, context, options) do
        Noizu.V3.CMS.Protocol.__cms_article__(__article__(ref, context, options), context, options)
      end
      def __cms_article__!(ref, context, options) do
        Noizu.V3.CMS.Protocol.__cms_article__!(__article__!(ref, context, options), context, options)
      end

      def __cms_article__(ref, property, context, options) do
        Noizu.V3.CMS.Protocol.__cms_article__(__article__(ref, context, options), property, context, options)
      end
      def __cms_article__!(ref, property, context, options) do
        Noizu.V3.CMS.Protocol.__cms_article__!(__article__!(ref, context, options), property, context, options)
      end
    end
  end

  def __after_compile__(_env, _bytecode) do
    nil
  end
end
