defmodule Noizu.V3.CMS.Meta.ArticleType.CMS do


  defmodule Default do


    def __update_tags__(_m, _ref, _context, _options), do: nil
    def __update_tags__!(_m, _ref, _context, _options), do: nil

    def __update_index__(_m, _ref, _context, _options), do: nil
    def __update_index__!(_m, _ref, _context, _options), do: nil

    def make_active(m, entity, for_version, context, options), do: nil
    def make_active!(m, entity, for_version, context, options), do: nil

    #-----------------------------
    # make_active/4
    #-----------------------------
    def make_active(m, entity, context, options) do
      # Entity may technically be a Version or Revision record.
      # This is fine as long as we can extract tags, and the details needed for the index.
      article = Noizu.V3.CMS.Protocol.article(entity, context, options)
      version = Noizu.V3.CMS.Protocol.version(entity, context, options)
      revision = Noizu.V3.CMS.Protocol.revision(entity, context, options)
      cond do
        version == nil -> {:error, :version_not_set}
        revision == nil -> {:error, :revision_not_set}
        :else ->
          m.__update_tags__(article, context, options)
          m.__update_index__(article, context, options)
      end
      entity
    end

    #-----------------------------
    # make_active!/4
    #-----------------------------
    def make_active!(m, entity, context, options) do
      # Entity may technically be a Version or Revision record.
      # This is fine as long as we can extract tags, and the details needed for the index.
      article = Noizu.V3.CMS.Protocol.article!(entity, context, options)
      version = Noizu.V3.CMS.Protocol.version!(entity, context, options)
      revision = Noizu.V3.CMS.Protocol.revision!(entity, context, options)
      cond do
        version == nil -> {:error, :version_not_set}
        revision == nil -> {:error, :revision_not_set}
        :else ->
          m.__update_tags__!(article, context, options)
          m.__update_index__!(article, context, options)
      end
      entity
    end

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


    def __initialize_version__(m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      version_entity = Noizu.V3.CMS.Protocol.__cms__(entity, :version, context, options)
      version_repo = version_entity.__repo__()

      revision_entity = Noizu.V3.CMS.Protocol.__cms__(entity, :revision, context, options)
      revision_repo = revision_entity.__repo__()

      # 1. Create Version
      version = version_repo.new_version(entity, context, options)
                |> version_repo.create(context, options[:create_options])

      # 2. If succesful create revision
      cond do
        !version -> throw {:error, {:creating_version, :create_failed}}
        :else ->
            article_info = article_info.__struct__.overwrite(article_info, [
              version: Noizu.ERP.ref(version),
              parent: Noizu.ERP.ref(article_info.version),
              revision: nil
            ], context, options)
            entity = Noizu.V3.CMS.Protocol.__set_article_info__(entity, article_info, context, options)
            revision = revision_repo.new_revision(entity, context, options)
                       |> revision_repo.create(context, options[:create_options])
            cond do
            !revision -> {:error, :create_revision}
            :else ->
              m.make_active(entity, revision, context, options)

              # Update identifier
              article_info = article_info.__struct__.overwrite(article_info, [
                revision: Noizu.ERP.ref(revision)
              ], context, options)
              entity = Noizu.V3.CMS.Protocol.__set_article_info__(entity, article_info, context, options)

              identifier = Noizu.ERP.id(article_info.article)
              {:ref, _, {{:ref, _v, {_article, version_path}}, revision_number}} = article_info.revision
              qualified_identifier = {:revision, {identifier, version_path, revision_number}}
              entity = put_in(entity, [Access.key(:identifier)], qualified_identifier)

              # Update tags and index
              m.__update_tags__(entity, context, options)
              m.__update_index__(entity, context, options)

              # Fin.
              entity
            end
      end
    end

    def __initialize_version__!(m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      version_entity = Noizu.V3.CMS.Protocol.__cms__!(entity, :version, context, options)
      version_repo = version_entity.__repo__()

      revision_entity = Noizu.V3.CMS.Protocol.__cms__!(entity, :revision, context, options)
      revision_repo = revision_entity.__repo__()

      # 1. Create Version
      version = version_repo.new_version!(entity, context, options)
                |> version_repo.create!(context, options[:create_options])

      # 2. If succesful create revision
      cond do
        !version -> throw {:error, {:creating_version, :create_failed}}
        :else ->
          article_info = article_info.__struct__.overwrite!(article_info, [
            version: Noizu.ERP.ref(version),
            parent: Noizu.ERP.ref(article_info.version),
            revision: nil
          ], context, options)
          entity = Noizu.V3.CMS.Protocol.__set_article_info__!(entity, article_info, context, options)
          revision = revision_repo.new_revision!(entity, context, options)
                     |> revision_repo.create!(context, options[:create_options])
          cond do
            !revision -> {:error, :create_revision}
            :else ->
              m.make_active!(entity, revision, context, options)

              # Update identifier
              article_info = article_info.__struct__.overwrite!(article_info, [
                revision: Noizu.ERP.ref(revision)
              ], context, options)
              entity = Noizu.V3.CMS.Protocol.__set_article_info__!(entity, article_info, context, options)

              identifier = Noizu.ERP.id(article_info.article)
              {:ref, _, {{:ref, _v, {_article, version_path}}, revision_number}} = article_info.revision
              qualified_identifier = {:revision, {identifier, version_path, revision_number}}
              entity = put_in(entity, [Access.key(:identifier)], qualified_identifier)

              # Update tags and index
              m.__update_tags__!(entity, context, options)
              m.__update_index__!(entity, context, options)

              # Fin.
              entity
          end
      end
    end

    def __populate_version__(m, entity, context, options) do
      # << if options[:nested_call] != :disabled
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

    def __populate_version__!(m, entity, context, options) do
      # << if options[:nested_call] != :disabled
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

      def __cms__() do
        Enum.map([:version, :revision, :article_info], &({&1, __cms__(&1)}))
      end
      def __cms__() do
        Enum.map([:version, :revision, :article_info], &({&1, __cms__!(&1)}))
      end

      def __cms__(:version), do: unquote(version)
      def __cms__(:revision), do: unquote(revision)
      def __cms__(:article_info), do: unquote(article_info)

      def __cms__!(:version), do: unquote(version)
      def __cms__!(:revision), do: unquote(revision)
      def __cms__!(:article_info), do: unquote(article_info)

      def __cms_info__(entity, context, options), do: nil
      def __cms_info__!(entity, context, options), do: nil

      def __cms_info__(entity, property, context, options), do: nil
      def __cms_info__!(entity, property, context, options), do: nil

      def __update_tags__(ref, context, options), do: @provider.__update_tags__(__MODULE__, ref, context, options)
      def __update_tags__!(ref, context, options), do: @provider.__update_tags__!(__MODULE__, ref, context, options)

      def __update_index__(ref, context, options), do: @provider.__update_index__(__MODULE__, ref, context, options)
      def __update_index__!(ref, context, options), do: @provider.__update_index__!(__MODULE__, ref, context, options)

      def __populate_version__(entity, context, options), do: @provider.__populate_version__(__MODULE__, entity, context, options)
      def __populate_version__!(entity, context, options), do: @provider.__populate_version__!(__MODULE__, entity, context, options)

      def __initialize_version__(entity, context, options), do: @provider.__initialize_version__(__MODULE__, entity, context, options)
      def __initialize_version__!(entity, context, options), do: @provider.__initialize_version__!(__MODULE__, entity, context, options)

      def make_active(ref, context, options), do: @provider.make_active(__MODULE__, ref, context, options)
      def make_active!(ref, context, options), do: @provider.make_active!(__MODULE__, ref, context, options)

      def make_active(ref, for_version, context, options), do: @provider.make_active(__MODULE__, ref, for_version, context, options)
      def make_active!(ref, for_version, context, options), do: @provider.make_active!(__MODULE__, ref, for_version, context, options)

      def active_revision(ref, context, options), do: @provider.active_revision(__MODULE__, ref, context, options)
      def active_revision!(ref, context, options), do: @provider.active_revision!(__MODULE__, ref, context, options)

      def revisions(ref, context, options), do: @provider.revisions(__MODULE__, ref, context, options)
      def revisions!(ref, context, options), do: @provider.revisions!(__MODULE__, ref, context, options)

      def versions(ref, context, options), do: @provider.versions(__MODULE__, ref, context, options)
      def versions!(ref, context, options), do: @provider.versions!(__MODULE__, ref, context, options)

      def tags(ref, context, options), do: @provider.tags(__MODULE__, ref, context, options)
      def tags!(ref, context, options), do: @provider.tags!(__MODULE__, ref, context, options)

      def set_tags(ref, tags, context, options), do: @provider.set_tags(__MODULE__, ref, tags, context, options)
      def set_tags!(ref, tags, context, options), do: @provider.set_tags!(__MODULE__, ref, tags, context, options)

      defoverridable
      [
        __cms__: 0,
        __cms__!: 0,
        __cms__: 1,
        __cms__!: 1,
        __cms_info__: 3,
        __cms_info__!: 3,
        __cms_info__: 4,
        __cms_info__!: 4,
        __update_tags__: 3,
        __update_tags__!: 3,
        __update_index__: 3,
        __update_index__!: 3,
        __populate_version__: 3,
        __populate_version__!: 3,
        __initialize_version__: 3,
        __initialize_version__!: 3,
        make_active: 3,
        make_active!: 3,
        make_active: 4,
        make_active!: 4,
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
      ]
    end
  end

  defmacro __before_compile__(_) do
  end
end
