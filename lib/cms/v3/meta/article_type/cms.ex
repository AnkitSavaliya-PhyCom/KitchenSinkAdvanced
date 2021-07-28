defmodule Noizu.V3.CMS.Meta.ArticleType.CMS do

  defmacro __using__(options \\ nil) do
    options = Macro.expand(options, __ENV__)
    version = options[:version] || Noizu.V3.CMS.Version
    revision = options[:revision] || Noizu.V3.CMS.Version.Revision
    article_info = options[:article_info] || Noizu.V3.CMS.Article.Info
    quote do
      def __version__(), do: unquote(version)
      def __revision__(), do: unquote(revision)
      def __article_info__(), do: unquote(article_info)

      def revision_to_id(revision), do: nil

      def populate_version(entity, _context, _options), do: entity
      def initialize_version(entity, _context, _options), do: entity

      defoverridable [
        __version__: 0,
        __revision__: 0,
        __article_info__: 0,

        revision_to_id: 1,

        populate_version: 3,
        populate_version!: 3,
        initialize_version: 3,
        initialize_version!: 3,
      ]
    end
  end

  defmacro __before_compile__(_) do
  end
end
