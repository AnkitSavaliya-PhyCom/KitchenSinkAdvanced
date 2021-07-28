defmodule Noizu.V3.CMS.Meta.ArticleType.Entity do

  defmodule Default do
    def __cms__(m), do: m
    def __cms__(m, property), do: {m, property}

    def __cms_article__(m, ref, _context, _options), do: {m, ref}
    def __cms_article__!(m, ref, _context, _options), do: {m, ref}

    def __cms_article__(m, ref, property, _context, _options), do: {m, {ref, property}}
    def __cms_article__!(m, ref, property, _context, _options), do: {m, {ref, property}}
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
    quote do
      alias Noizu.V3.CMS.Meta.ArticleType.Entity.Default, as: Provider
      def __cms_manager__(), do:  @__nzdo__poly_base.__cms_manager__()

      def __cms__(), do: @__nzdo__poly_base.__cms__()
      def __cms__(property), do: @__nzdo__poly_base.__cms__(property)

      def __cms_article__(ref, context, options), do: Provider.__cms_article__(__MODULE__, ref, context, options)
      def __cms_article__!(ref, context, options), do: Provider.__cms_article__!(__MODULE__, ref, context, options)

      def __cms_article__(ref, property, context, options), do: Provider.__cms_article__(__MODULE__, ref, property, context, options)
      def __cms_article__!(ref, property, context, options), do: Provider.__cms_article__!(__MODULE__, ref, property, context, options)

      def update_article_info(ref, context, options), do: Provider.update_article_info(__MODULE__, ref, context, options)
      def update_article_info!(ref, context, options), do: Provider.update_article_info!(__MODULE__, ref, context, options)

      def init_article_info(ref, context, options), do: Provider.init_article_info(__MODULE__, ref, context, options)
      def init_article_info!(ref, context, options), do: Provider.init_article_info!(__MODULE__, ref, context, options)

      def versioning_record?(ref, context, options), do: Provider.versioning_record?(__MODULE__, ref, context, options)
      def versioning_record!(ref, context, options), do: Provider.versioning_record!(__MODULE__, ref, context, options)

      defoverridable [
        __cms__: 0,
        __cms__: 1,
        __cms_article__: 3,
        __cms_article__: 4,
        __cms_article__!: 3,
        __cms_article__!: 4,

        update_article_info: 3,
        update_article_info!: 3,

        init_article_info: 3,
        init_article_info!: 3,

        versioning_record?: 3,
        versioning_record!: 3,

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
