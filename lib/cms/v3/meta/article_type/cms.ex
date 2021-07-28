defmodule Noizu.V3.CMS.Meta.ArticleType.CMS do


  defmodule Default do
    def set_active(_m, _ref,_context, _options), do: nil
    def set_active!(_m, _ref,_context, _options), do: nil

    def active_revision(_m, _ref,_context, _options), do: nil
    def active_revision!(_m, _ref,_context, _options), do: nil

    def revisions(_m, _ref,_context, _options), do: nil
    def revisions!(_m, _ref,_context, _options), do: nil

    def versions(_m, _ref,_context, _options), do: nil
    def versions!(_m, _ref,_context, _options), do: nil

    def versions(_m, _ref,_context, _options), do: nil
    def versions!(_m, _ref,_context, _options), do: nil

    def tags(_m, _ref,_context, _options), do: nil
    def tags!(_m, _ref,_context, _options), do: nil

    def set_tags(_m, _ref, _tags, _context, _options), do: nil
    def set_tags!(_m, _ref, _tags, _context, _options), do: nil

    def version_sequencer(_m, _ref, _context, _optiosm), do: nil
    def version_sequencer!(_m, _ref, _context, _optiosm), do: nil

    def initialize_version(m, entity, context, options) do
      # options = put_in(options, [:active_revision], true)
      #    case caller.cms_version().create(entity, context, options) do
      #      {:ok, {version, revision}} ->
      #        entity = entity
      #                 |> Noizu.Cms.V2.Proto.set_version(version, context, options)
      #                 |> Noizu.Cms.V2.Proto.set_revision(revision, context, options)
      #                 |> Noizu.Cms.V2.Proto.set_parent(version.parent, context, options)
      #        v_id = Noizu.Cms.V2.Proto.versioned_identifier(entity, context, options)
      #        entity = entity
      #                 |> put_in([Access.key(:identifier)], v_id)
      #
      #        caller.cms_tags().update(entity, context, options)
      #        caller.cms_index().update(entity, context, options)
      #
      #        entity
      #      e -> throw "initialize_versioning_records error: #{inspect e}"
      #    end
      entity
    end

    def initialize_version!(m, entity, context, options) do
      # options = put_in(options, [:active_revision], true)
      #    case caller.cms_version().create(entity, context, options) do
      #      {:ok, {version, revision}} ->
      #        entity = entity
      #                 |> Noizu.Cms.V2.Proto.set_version(version, context, options)
      #                 |> Noizu.Cms.V2.Proto.set_revision(revision, context, options)
      #                 |> Noizu.Cms.V2.Proto.set_parent(version.parent, context, options)
      #        v_id = Noizu.Cms.V2.Proto.versioned_identifier(entity, context, options)
      #        entity = entity
      #                 |> put_in([Access.key(:identifier)], v_id)
      #
      #        caller.cms_tags().update(entity, context, options)
      #        caller.cms_index().update(entity, context, options)
      #
      #        entity
      #      e -> throw "initialize_versioning_records error: #{inspect e}"
      #    end
      entity
    end



    def populate_version(m, entity, context, options) do
      # << if options[:nested_create] != :disabled
      # version = Noizu.Cms.V2.Proto.get_version(entity, context, options)
      #    version_ref = caller.cms_version().ref(version)
      #
      #    revision = Noizu.Cms.V2.Proto.get_version(entity, context, options)
      #    revision_ref = caller.cms_revision().ref(revision)
      #
      #    # if active revision then update version table, otherwise only update revision.
      #    active_revision_ref = caller.cms_revision_repo().active(version_ref, context, options)
      #
      #    if active_revision_ref do
      #      if active_revision_ref == revision_ref || options[:active_revision] == true do
      #        case caller.cms_version().update(entity, context, options) do
      #          {:ok, _} ->
      #            entity
      #          e -> throw "1. populate_versioning_records error: #{inspect e}"
      #        end
      #      else
      #        case caller.cms_revision().update(entity, context, options) do
      #          {:ok, _} ->
      #            entity
      #          e -> throw "2. populate_versioning_records error: #{inspect e}"
      #        end
      #      end
      #
      #    else
      #      options_a = put_in(options, [:active_revision], true)
      #      case caller.cms_version().update(entity, context, options_a) do
      #        {:ok, _} ->
      #          entity
      #        e ->
      #          throw "3. populate_versioning_records error: #{inspect e}"
      #      end
      #    end
      entity
    end

    def populate_version!(m, entity, context, options) do
      # << if options[:nested_create] != :disabled
      # version = Noizu.Cms.V2.Proto.get_version(entity, context, options)
      #    version_ref = caller.cms_version().ref(version)
      #
      #    revision = Noizu.Cms.V2.Proto.get_version(entity, context, options)
      #    revision_ref = caller.cms_revision().ref(revision)
      #
      #    # if active revision then update version table, otherwise only update revision.
      #    active_revision_ref = caller.cms_revision_repo().active(version_ref, context, options)
      #
      #    if active_revision_ref do
      #      if active_revision_ref == revision_ref || options[:active_revision] == true do
      #        case caller.cms_version().update(entity, context, options) do
      #          {:ok, _} ->
      #            entity
      #          e -> throw "1. populate_versioning_records error: #{inspect e}"
      #        end
      #      else
      #        case caller.cms_revision().update(entity, context, options) do
      #          {:ok, _} ->
      #            entity
      #          e -> throw "2. populate_versioning_records error: #{inspect e}"
      #        end
      #      end
      #
      #    else
      #      options_a = put_in(options, [:active_revision], true)
      #      case caller.cms_version().update(entity, context, options_a) do
      #        {:ok, _} ->
      #          entity
      #        e ->
      #          throw "3. populate_versioning_records error: #{inspect e}"
      #      end
      #    end
      entity
    end

  end

  defmacro __using__(options \\ nil) do
    options = Macro.expand(options, __ENV__)
    version = options[:version] || Noizu.V3.CMS.Version
    revision = options[:revision] || Noizu.V3.CMS.Version.Revision
    article_info = options[:article_info] || Noizu.V3.CMS.Article.Info
    quote do
      @provider Noizu.V3.CMS.Meta.ArticleType.CMS.Default
      def __version__(), do: unquote(version)
      def __revision__(), do: unquote(revision)
      def __article_info__(), do: unquote(article_info)

      def populate_version(entity, context, options), do: @provider.populate_version(__MODULE__, entity, context, options)
      def populate_version!(entity, context, options), do: @provider.populate_version!(__MODULE__, entity, context, options)

      def initialize_version(entity, context, options), do: @provider.initialize_version(__MODULE__, entity, context, options)
      def initialize_version!(entity, context, options), do: @provider.initialize_version!(__MODULE__, entity, context, options)

      def set_active(ref, context, options), do: @provider.set_active(__MODULE__, ref, context, options)
      def set_active!(ref, context, options), do: @provider.set_active!(__MODULE__, ref, context, options)

      def active_revision(ref, context, options), do: @provider.active_revision(__MODULE__, ref, context, options)
      def active_revision!(ref, context, options), do: @provider.active_revision!(__MODULE__, ref, context, options)

      def revisions(ref, context, options), do: @provider.revisions(__MODULE__, ref, context, options)
      def revisions!(ref, context, options), do: @provider.revisions!(__MODULE__, ref, context, options)

      def versions(ref, context, options), do: @provider.versions(__MODULE__, ref, context, options)
      def versions!(ref, context, options), do: @provider.versions!(__MODULE__, ref, context, options)

      def versions(ref, context, options), do: @provider.versions(__MODULE__, ref, context, options)
      def versions!(ref, context, options), do: @provider.versions!(__MODULE__, ref, context, options)

      def tags(ref, context, options), do: @provider.tags(__MODULE__, ref, context, options)
      def tags!(ref, context, options), do: @provider.tags!(__MODULE__, ref, context, options)

      def set_tags(ref, tags, context, options), do: @provider.set_tags(__MODULE__, ref, tags, context, options)
      def set_tags!(ref, tags, context, options), do: @provider.set_tags!(__MODULE__, ref, tags, context, options)

      def version_sequencer(ref, context, options), do: @provider.version_sequencer(__MODULE__, ref, context, options)
      def version_sequencer!(ref, context, options), do: @provider.version_sequencer!(__MODULE__, ref, context, options)

      defoverridable [
        __version__: 0,
        __revision__: 0,
        __article_info__: 0,

        populate_version: 3,
        populate_version!: 3,
        initialize_version: 3,
        initialize_version!: 3,

        set_active: 3,
        set_active!: 3,

        active_revision: 3,
        active_revision!: 3,

        revisions: 3,
        revisions!: 3,

        versions: 3,
        versions!: 3,

        tags: 3,
        tags!: 3,

        set_tags: 4,
        set_tags!: 4,

        version_sequencer: 3,
        version_sequencer!: 3,

      ]
    end
  end

  defmacro __before_compile__(_) do
  end
end
