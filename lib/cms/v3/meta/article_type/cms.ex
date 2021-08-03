defmodule Noizu.V3.CMS.Meta.ArticleType.CMS do





  defmodule Default do
    def __update_tags__(_m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)

      tag_table = Noizu.V3.CMS.Protocol.__cms__(entity, :tag, context, options)
      tag_table.delete(article_info.article)

      if (article_info.tags) do
          Enum.map(MapSet.to_list(article_info.tags), fn(tag) ->
            struct(tag_table, [article: article_info.article, tag: tag])
            |> tag_table.write()
          end)
      end
    end

    def __update_tags__!(_m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)

      tag_table = Noizu.V3.CMS.Protocol.__cms__!(entity, :tag, context, options)
      tag_table.delete!(article_info.article)
      if (article_info.tags) do
        Enum.map(MapSet.to_list(article_info.tags), fn(tag) ->
          struct(tag_table, [article: article_info.article, tag: tag])
          |> tag_table.write!()
        end)
      end
    end

    def __update_index__(_m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      index_table = Noizu.V3.CMS.Protocol.__cms__(entity, :index, context, options)
      struct(index_table, [
        article: article_info.article,
        status: article_info.status,
        manager: article_info.manager,
        article_type: article_info.article_type,
        editor: article_info.editor,
        created_on: article_info.time_stamp.created_on && DateTime.to_unix(article_info.time_stamp.created_on),
        modified_on: article_info.time_stamp.modified_on && DateTime.to_unix(article_info.time_stamp.modified_on),
        active_version: article_info.version,
        active_revision: article_info.revision]) |> index_table.write()
    end



    def __update_index__!(_m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      index_table = Noizu.V3.CMS.Protocol.__cms__!(entity, :index, context, options)
      struct(index_table, [
        article: article_info.article,
        status: article_info.status,
        manager: article_info.manager,
        article_type: article_info.article_type,
        editor: article_info.editor,
        created_on: article_info.time_stamp.created_on && DateTime.to_unix(article_info.time_stamp.created_on),
        modified_on: article_info.time_stamp.modified_on && DateTime.to_unix(article_info.time_stamp.modified_on),
        active_version: article_info.version,
        active_revision: article_info.revision]) |> index_table.write!()
    end


    def make_active(m, entity, for_version, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      for_version_ref = Noizu.ERP.ref(for_version)
      cond do
        !article_info -> throw "article_info not set"
        !article_info.version -> throw "version not set"
        !article_info.revision -> throw "revision not set"
        for_version_ref != article_info.version -> throw "attempting to make a revision active on the wrong version"
        :else ->
          # check if version is active as we will then need to update indexing as well.
          active_version_table = Noizu.V3.CMS.Protocol.__cms__(entity, :active_version, context, options)
          active_revision_table = Noizu.V3.CMS.Protocol.__cms__(entity, :active_revision, context, options)
          article_active_version = active_version_table.read(article_info.article)
          cond do
            article_active_version == nil -> m.make_active(entity, context, options)
            article_active_version == article_info.version -> m.make_active(entity, context, options)
            :else ->
            struct(active_revision_table, [
              version: article_info.version,
              revision: article_info.revision
            ]) |> active_revision_table.write()
          end
      end
      entity
    end
    def make_active!(m, entity, for_version, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      for_version_ref = Noizu.ERP.ref(for_version)

      cond do
        !article_info -> throw "article_info not set"
        !article_info.version -> throw "version not set"
        !article_info.revision -> throw "revision not set"
        for_version_ref != article_info.version -> throw "attempting to make a revision active on the wrong version"
        :else ->
          # check if version is active as we will then need to update indexing as well.
          active_version_table = Noizu.V3.CMS.Protocol.__cms__!(entity, :active_version, context, options)
          active_revision_table = Noizu.V3.CMS.Protocol.__cms__!(entity, :active_revision, context, options)
          article_active_version = active_version_table.read!(article_info.article)
          cond do
            article_active_version == nil -> m.make_active!(entity, context, options)
            article_active_version == article_info.version -> m.make_active!(entity, context, options)
            :else ->
              struct(active_revision_table, [
                version: article_info.version,
                revision: article_info.revision
              ]) |> active_revision_table.write!()
          end
      end
      entity
    end

    #-----------------------------
    # make_active/4
    #-----------------------------
    def make_active(m, entity, context, options) do
      # Entity may technically be a Version or Revision record.
      # This is fine as long as we can extract tags, and the details needed for the index.
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)

      cond do
        article_info.version == nil -> {:error, :version_not_set}
        article_info.revision == nil -> {:error, :revision_not_set}
        :else ->
          m.__update_tags__(entity, context, options)
          m.__update_index__(entity, context, options)

          active_version_table = Noizu.V3.CMS.Protocol.__cms__(entity, :active_version, context, options)
          active_revision_table = Noizu.V3.CMS.Protocol.__cms__(entity, :active_revision, context, options)

          #...................................
          # Needs to be handled externally as providers with multiple persistence layers will want to track this info as well.
          struct(active_version_table, [article: article_info.article, version: article_info.version])
          |> active_version_table.write()

          struct(active_revision_table, [version: article_info.version, revision: article_info.revision])
          |> active_revision_table.write()
      end
      entity
    end

    #-----------------------------
    # make_active!/4
    #-----------------------------
    def make_active!(m, entity, context, options) do
      # Entity may technically be a Version or Revision record.
      # This is fine as long as we can extract tags, and the details needed for the index.
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)

      cond do
        article_info.version == nil -> {:error, :version_not_set}
        article_info.revision == nil -> {:error, :revision_not_set}
        :else ->
          m.__update_tags__!(entity, context, options)
          m.__update_index__!(entity, context, options)

          active_version_table = Noizu.V3.CMS.Protocol.__cms__!(entity, :active_version, context, options)
          active_revision_table = Noizu.V3.CMS.Protocol.__cms__!(entity, :active_revision, context, options)

          #...................................
          # Needs to be handled externally as providers with multiple persistence layers will want to track this info as well.
          struct(active_version_table, [article: article_info.article, version: article_info.version])
          |> active_version_table.write!()

          struct(active_revision_table, [version: article_info.version, revision: article_info.revision])
          |> active_revision_table.write!()
      end
      entity
    end


    def active_version(_m, ref, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(ref, context, options)
      active_version_table = Noizu.V3.CMS.Protocol.__cms__(ref, :active_version, context, options)
      cond do
        !article_info -> throw "article_info not found"
        !article_info.article -> throw "article_info.article not found"
        av = active_version_table.read(article_info.article) -> av.version
        :else -> nil
      end
    end
    def active_version!(_m, ref, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(ref, context, options)
      active_version_table = Noizu.V3.CMS.Protocol.__cms__!(ref, :active_version, context, options)
      cond do
        !article_info -> throw "article_info not found"
        !article_info.article -> throw "article_info.article not found"
        av = active_version_table.read!(article_info.article) -> av.version
        :else -> nil
      end
    end

    def active_revision(_m, ref, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(ref, context, options)
      active_version_table = Noizu.V3.CMS.Protocol.__cms__(ref, :active_version, context, options)
      active_revision_table = Noizu.V3.CMS.Protocol.__cms__(ref, :active_revision, context, options)
      cond do
        !article_info -> throw "article_info not found"
        !article_info.article -> throw "article_info.article not found"
        av = active_version_table.read(article_info.article) ->
          cond do
            ar = active_revision_table.read(av.version) -> ar.revision
            :else -> nil
          end
        :else -> nil
      end
    end
    def active_revision!(_m, ref, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(ref, context, options)
      active_version_table = Noizu.V3.CMS.Protocol.__cms__!(ref, :active_version, context, options)
      active_revision_table = Noizu.V3.CMS.Protocol.__cms__!(ref, :active_revision, context, options)
      cond do
        !article_info -> throw "article_info not found"
        !article_info.article -> throw "article_info.article not found"
        av = active_version_table.read!(article_info.article) ->
          cond do
            ar = active_revision_table.read!(av.version) -> ar.revision
            :else -> nil
          end
        :else -> nil
      end
    end

    def revisions(_m, _ref, _context, _options), do: nil
    def revisions!(_m, _ref, _context, _options), do: nil

    def versions(_m, _ref, _context, _options), do: nil
    def versions!(_m, _ref, _context, _options), do: nil

    def tags(_m, _ref, _context, _options), do: nil
    def tags!(_m, _ref, _context, _options), do: nil

    def set_tags(_m, _ref, _tags, _context, _options), do: nil
    def set_tags!(_m, _ref, _tags, _context, _options), do: nil




    def __update_version__(_m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      version = article_info.version |> Noizu.ERP.entity
      #...
      updated_version = version.__struct__.overwrite(version, [
        modified_on: article_info.time_stamp.modified_on,
        editor: article_info.editor,
        status: article_info.status,
      ], context, options)
      updated_version = (if (updated_version != version) do
                           updated_version.__struct__.__repo__.update(updated_version, Noizu.ElixirCore.CallingContext.system(context))
                         else
                           updated_version
                         end)

      #...
      article_info = article_info.__struct__.overwrite(article_info, [
        version: Noizu.ERP.ref(updated_version),
      ], context, options)
      Noizu.V3.CMS.Protocol.__set_article_info__(entity, article_info, context, options)
    end

    def __update_version__!(_m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      version = article_info.version |> Noizu.ERP.entity
      #...
      updated_version = version.__struct__.overwrite!(version, [
        modified_on: article_info.time_stamp.modified_on,
        editor: article_info.editor,
        status: article_info.status,
      ], context, options)
      updated_version = (if (updated_version != version) do
                           updated_version.__struct__.__repo__.update!(updated_version, Noizu.ElixirCore.CallingContext.system(context))
                         else
                           updated_version
                         end)

      #...
      article_info = article_info.__struct__.overwrite!(article_info, [
        version: Noizu.ERP.ref(updated_version),
      ], context, options)
      Noizu.V3.CMS.Protocol.__set_article_info__!(entity, article_info, context, options)
    end

    def __update_revision__(_m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      revision = article_info.revision |> Noizu.ERP.entity
      #...
      updated_revision = revision.__struct__.overwrite(revision, [
        modified_on: article_info.time_stamp.modified_on,
        editor: article_info.editor,
        status: article_info.status,
        version: article_info.version,
      ], context, options)
      updated_revision = (if (updated_revision != revision) do
                            updated_revision.__struct__.__repo__.update(updated_revision, Noizu.ElixirCore.CallingContext.system(context))
                         else
                            updated_revision
                         end)
      #...
      article_info = article_info.__struct__.overwrite(article_info, [
        revision: Noizu.ERP.ref(updated_revision),
      ], context, options)
      Noizu.V3.CMS.Protocol.__set_article_info__(entity, article_info, context, options)
    end

    def __update_revision__!(_m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      revision = article_info.revision |> Noizu.ERP.entity
      #...
      updated_revision = revision.__struct__.overwrite!(revision, [
        modified_on: article_info.time_stamp.modified_on,
        editor: article_info.editor,
        status: article_info.status,
        version: article_info.version,
      ], context, options)
      updated_revision = (if (updated_revision != revision) do
                            updated_revision.__struct__.__repo__.update!(updated_revision, Noizu.ElixirCore.CallingContext.system(context))
                          else
                            updated_revision
                          end)
      #...
      article_info = article_info.__struct__.overwrite!(article_info, [
        revision: Noizu.ERP.ref(updated_revision),
      ], context, options)
      Noizu.V3.CMS.Protocol.__set_article_info__!(entity, article_info, context, options)
    end

    def __initialize_version__(m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      version_entity = Noizu.V3.CMS.Protocol.__cms__(entity, :version, context, options).__entity__()
      version_repo = version_entity.__repo__()

      revision_entity = Noizu.V3.CMS.Protocol.__cms__(entity, :revision, context, options).__entity__()
      revision_repo = revision_entity.__repo__()

      # 1. Create Version
      version = version_repo.new_version(entity, context, options)
                |> version_repo.create(context, options[:create_options])

      # 2. If successful create revision
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
              # Update identifier
              article_info = article_info.__struct__.overwrite(article_info, [
                revision: Noizu.ERP.ref(revision)
              ], context, options)
              entity = Noizu.V3.CMS.Protocol.__set_article_info__(entity, article_info, context, options)

              identifier = Noizu.ERP.id(article_info.article)
              {:ref, _, {{:ref, _v, {_article, version_path}}, revision_number}} = article_info.revision
              qualified_identifier = {:revision, {entity.__struct__, identifier, version_path, revision_number}}
              entity = put_in(entity, [Access.key(:identifier)], qualified_identifier)

              revision_entity.archive(revision, entity, context, options)
              |> revision_repo.update(context, options[:create_options])

              cond do
                options[:active] == false ->
                  m.make_active(entity, article_info.version, context, options)
                :else ->
                  # Update tags and index
                  m.__update_tags__(entity, context, options)
                  m.__update_index__(entity, context, options)
                  m.make_active(entity, context, options)
              end

              # Fin.
              entity
          end
      end
    end

    def __initialize_version__!(m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      version_entity = Noizu.V3.CMS.Protocol.__cms__!(entity, :version, context, options).__entity__()
      version_repo = version_entity.__repo__()

      revision_entity = Noizu.V3.CMS.Protocol.__cms__!(entity, :revision, context, options).__entity__()
      revision_repo = revision_entity.__repo__()

      # 1. Create Version
      version = version_repo.new_version!(entity, context, options)
                |> version_repo.create!(context, options[:create_options])

      # 2. Create revision
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
              # Update identifier
              article_info = article_info.__struct__.overwrite!(article_info, [
                revision: Noizu.ERP.ref(revision)
              ], context, options)
              entity = Noizu.V3.CMS.Protocol.__set_article_info__!(entity, article_info, context, options)

              identifier = Noizu.ERP.id(article_info.article)
              {:ref, _, {{:ref, _v, {_article, version_path}}, revision_number}} = article_info.revision
              qualified_identifier = {:revision, {entity.__struct__, identifier, version_path, revision_number}}
              entity = put_in(entity, [Access.key(:identifier)], qualified_identifier)

              revision_entity.archive!(revision, entity, context, options)
              |> revision_repo.update!(context, options[:create_options])

              cond do
                options[:active] == false ->
                  m.make_active!(entity, article_info.version, context, options)
                :else ->
                  # Update tags and index
                  m.__update_tags__!(entity, context, options)
                  m.__update_index__!(entity, context, options)
                  m.make_active!(entity, context, options)
              end

              # Fin.
              entity
          end
      end
    end

    def __populate_version__(m, entity, context, options) do
      cond do
        options[:nested_call] -> entity
        !options[:nested_call] ->
          article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)
          active_revision = Noizu.V3.CMS.Protocol.active_revision(entity, context, options)
          active_revision_ref = Noizu.ERP.ref(active_revision)
          cond do
            !active_revision_ref ->
              options_a = put_in(options, [:active_revision], true)
              entity
              |> m.__update_version__(context, options_a)
              |> m.__update_revision__(context, options_a)

            options[:active_revision]->
              entity = entity
                       |> m.__update_version__(context, options)
                       |> m.__update_revision__(context, options)

              m.__update_tags__(entity, context, options)
              m.__update_index__(entity, context, options)
              m.make_active(entity, context, options)
              entity

            active_revision_ref == article_info.revision ->
              entity = entity
                       |> m.__update_version__(context, options)
                       |> m.__update_revision__(context, options)

              m.__update_tags__(entity, context, options)
              m.__update_index__(entity, context, options)
              m.make_active(entity, context, options)
              entity

            :else ->
              entity
              |> m.__update_revision__(context, options)
          end
      end
    end

    def __populate_version__!(m, entity, context, options) do
      cond do
        options[:nested_call] -> entity
        !options[:nested_call] ->
          article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
          active_revision = Noizu.V3.CMS.Protocol.active_revision!(entity, context, options)
          active_revision_ref = Noizu.ERP.ref(active_revision)
          cond do
            !active_revision_ref ->
              options_a = put_in(options, [:active_revision], true)
              entity
              |> m.__update_revision__!(context, options_a)
              |> m.__update_version__!(context, options_a)
            options[:active_revision]->
              entity = entity
                       |> m.__update_revision__!(context, options)
                       |> m.__update_version__!(context, options)

              m.__update_tags__!(entity, context, options)
              m.__update_index__!(entity, context, options)
              m.make_active!(entity, context, options)
              entity

            active_revision_ref == article_info.revision ->
              entity = entity
                       |> m.__update_revision__!(context, options)
                       |> m.__update_version__!(context, options)

              m.__update_tags__!(entity, context, options)
              m.__update_index__!(entity, context, options)
              m.make_active!(entity, context, options)
              entity

            :else ->
              entity
              |> m.__update_revision__!(context, options)
          end
      end
    end

    def new_version(m, entity, context, options) do
      options_b = cond do
                    options[:active] == nil -> put_in(options || [], [:active], false)
                    :else -> options
                  end
      m.__initialize_version__(entity, context, options_b)
      |> entity.__struct__.__repo__().create(context, options)
    end

    def new_version!(m, entity, context, options) do
      options_b = cond do
                    options[:active] == nil -> put_in(options || [], [:active], false)
                    :else -> options
                  end
      m.__initialize_version__!(entity, context, options_b)
      |> entity.__struct__.__repo__().create!(context, options)
    end


    def new_revision(m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      revision_entity = Noizu.V3.CMS.Protocol.__cms__(entity, :revision, context, options).__entity__()
      revision_repo = revision_entity.__repo__()
      revision = revision_repo.new_revision(entity, context, options)
                 |> revision_repo.create(context, options[:create_options])
      cond do
        !revision -> throw {:error, :create_revision}
        :else ->
          # Update identifier
          article_info = article_info.__struct__.overwrite(article_info, [
            revision: Noizu.ERP.ref(revision),
            editor: revision.editor,
            status: revision.status
          ], context, options)
          entity = Noizu.V3.CMS.Protocol.__set_article_info__(entity, article_info, context, options)

          identifier = Noizu.ERP.id(article_info.article)
          {:ref, _, {{:ref, _v, {_article, version_path}}, revision_number}} = article_info.revision
          qualified_identifier = {:revision, {entity.__struct__,  identifier, version_path, revision_number}}
          entity = put_in(entity, [Access.key(:identifier)], qualified_identifier)

          revision_entity.archive(revision, entity, context, options)
          |> revision_repo.update(context, options[:create_options])

          entity = cond do
                     options[:active] == true ->
                       active_version = Noizu.V3.CMS.Protocol.active_version(entity, context, options)
                       active_version_ref = Noizu.ERP.ref(active_version)
                       entity = m.__update_version__(entity, context, options)
                       cond do
                         active_version_ref == article_info.version ->
                           # Update tags and index
                           m.__update_tags__(entity, context, options)
                           m.__update_index__(entity, context, options)
                           m.make_active(entity, context, options)
                         :else ->
                           m.make_active(entity, article_info.version, context, options)
                       end
                     :else -> entity
                   end

          # Fin.
          entity |> entity.__struct__.__repo__().create(context, options)
      end
    end

    def new_revision!(m, entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      revision_entity = Noizu.V3.CMS.Protocol.__cms__!(entity, :revision, context, options).__entity__()
      revision_repo = revision_entity.__repo__()
      revision = revision_repo.new_revision!(entity, context, options)
                 |> revision_repo.create!(context, options[:create_options])
      cond do
        !revision -> throw {:error, :create_revision}
        :else ->
          # Update identifier
          article_info = article_info.__struct__.overwrite!(article_info, [
            revision: Noizu.ERP.ref(revision),
            editor: revision.editor,
            status: revision.status
          ], context, options)
          entity = Noizu.V3.CMS.Protocol.__set_article_info__!(entity, article_info, context, options)

          identifier = Noizu.ERP.id(article_info.article)
          {:ref, _, {{:ref, _v, {_article, version_path}}, revision_number}} = article_info.revision
          qualified_identifier = {:revision, {entity.__struct__, identifier, version_path, revision_number}}
          entity = put_in(entity, [Access.key(:identifier)], qualified_identifier)

          revision_entity.archive!(revision, entity, context, options)
          |> revision_repo.update!(context, options[:create_options])

          entity = cond do
                     options[:active] == true ->
                       active_version = Noizu.V3.CMS.Protocol.active_version!(entity, context, options)
                       active_version_ref = Noizu.ERP.ref(active_version)
                       entity = m.__update_version__!(entity, context, options)
                       cond do
                         active_version_ref == article_info.version ->
                           # Update tags and index
                           m.__update_tags__!(entity, context, options)
                           m.__update_index__!(entity, context, options)
                           m.make_active!(entity, context, options)
                         :else ->
                           m.make_active!(entity, article_info.version, context, options)
                       end
                     :else -> entity
                   end
          # ...

          # Fin.
          entity |> entity.__struct__.__repo__().create!(context, options)
      end
    end



  end

  defmacro __using__(options \\ nil) do
    options = Macro.expand(options, __ENV__)
    version = options[:version] || Noizu.V3.CMS.Version
    revision = options[:revision] || Noizu.V3.CMS.Version.Revision
    article_info = options[:article_info] || Noizu.V3.CMS.Article.Info
    tag_table = options[:tag_table] || Noizu.V3.CMS.Database.Article.Tag.Table
    index_table = options[:index_table] || Noizu.V3.CMS.Database.Article.Index.Table
    active_version_table = options[:active_version_table] || Noizu.V3.CMS.Database.Article.Active.Version.Table
    active_revision_table = options[:active_revision_table] || Noizu.V3.CMS.Database.Article.Active.Version.Revision.Table

    quote do
      @provider Noizu.V3.CMS.Meta.ArticleType.CMS.Default

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms__() do
        Enum.map([:version, :revision, :article_info], &({&1, __cms__(&1)}))
      end
      def __cms__!() do
        Enum.map([:version, :revision, :article_info], &({&1, __cms__!(&1)}))
      end

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms__(:version), do: unquote(version)
      def __cms__(:revision), do: unquote(revision)
      def __cms__(:article_info), do: unquote(article_info)
      def __cms__(:tag), do: unquote(tag_table)
      def __cms__(:index), do: unquote(index_table)
      def __cms__(:active_version), do: unquote(active_version_table)
      def __cms__(:active_revision), do: unquote(active_revision_table)




      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms__!(:version), do: unquote(version)
      def __cms__!(:revision), do: unquote(revision)
      def __cms__!(:article_info), do: unquote(article_info)
      def __cms__!(:tag), do: unquote(tag_table)
      def __cms__!(:index), do: unquote(index_table)
      def __cms__!(:active_version), do: unquote(active_version_table)
      def __cms__!(:active_revision), do: unquote(active_revision_table)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms_info__(entity, context, options), do: nil
      def __cms_info__!(entity, context, options), do: nil

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms_info__(entity, property, context, options), do: nil
      def __cms_info__!(entity, property, context, options), do: nil

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __update_version__(entity, context, options), do: @provider.__update_version__(__MODULE__, entity, context, options)
      def __update_version__!(entity, context, options), do: @provider.__update_version__!(__MODULE__, entity, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __update_revision__(entity, context, options), do: @provider.__update_revision__(__MODULE__, entity, context, options)
      def __update_revision__!(entity, context, options), do: @provider.__update_revision__!(__MODULE__, entity, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __update_tags__(ref, context, options), do: @provider.__update_tags__(__MODULE__, ref, context, options)
      def __update_tags__!(ref, context, options), do: @provider.__update_tags__!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __update_index__(ref, context, options), do: @provider.__update_index__(__MODULE__, ref, context, options)
      def __update_index__!(ref, context, options), do: @provider.__update_index__!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __populate_version__(entity, context, options), do: @provider.__populate_version__(__MODULE__, entity, context, options)
      def __populate_version__!(entity, context, options), do: @provider.__populate_version__!(__MODULE__, entity, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __initialize_version__(entity, context, options), do: @provider.__initialize_version__(__MODULE__, entity, context, options)
      def __initialize_version__!(entity, context, options), do: @provider.__initialize_version__!(__MODULE__, entity, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def make_active(ref, context, options), do: @provider.make_active(__MODULE__, ref, context, options)
      def make_active!(ref, context, options), do: @provider.make_active!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def make_active(ref, for_version, context, options), do: @provider.make_active(__MODULE__, ref, for_version, context, options)
      def make_active!(ref, for_version, context, options), do: @provider.make_active!(__MODULE__, ref, for_version, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def active_version(ref, context, options), do: @provider.active_version(__MODULE__, ref, context, options)
      def active_version!(ref, context, options), do: @provider.active_version!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def active_revision(ref, context, options), do: @provider.active_revision(__MODULE__, ref, context, options)
      def active_revision!(ref, context, options), do: @provider.active_revision!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def revisions(ref, context, options), do: @provider.revisions(__MODULE__, ref, context, options)
      def revisions!(ref, context, options), do: @provider.revisions!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def versions(ref, context, options), do: @provider.versions(__MODULE__, ref, context, options)
      def versions!(ref, context, options), do: @provider.versions!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def tags(ref, context, options), do: @provider.tags(__MODULE__, ref, context, options)
      def tags!(ref, context, options), do: @provider.tags!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def set_tags(ref, tags, context, options), do: @provider.set_tags(__MODULE__, ref, tags, context, options)
      def set_tags!(ref, tags, context, options), do: @provider.set_tags!(__MODULE__, ref, tags, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def new_version(entity, context, options \\ nil), do: @provider.new_version(__MODULE__, entity, context, options)
      def new_version!(entity, context, options \\ nil), do: @provider.new_version!(__MODULE__, entity, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def new_revision(entity, context, options \\ nil), do: @provider.new_revision(__MODULE__, entity, context, options)
      def new_revision!(entity, context, options \\ nil), do: @provider.new_revision!(__MODULE__, entity, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      defoverridable [
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
        active_version: 3,
        active_version!: 3,
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
        new_version: 2,
        new_version: 3,
        new_version!: 2,
        new_version!: 3,

        new_revision: 2,
        new_revision: 3,
        new_revision!: 2,
        new_revision!: 3,
      ]
      @file "#{__ENV__.file}:#{__ENV__.line}"
    end
  end

  defmacro __before_compile__(_) do
  end
end
