#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Version.Revision do
  use Noizu.V3.CMS.ArticleType.Versioning
  @vsn 1.0
  @sref "cms-article-revision"
  @persistence_layer {Noizu.V3.CMS.Database, Noizu.V3.CMS.Database.Article.Version.Revision.Table, [cascade?: true, cascade_block?: true]}
  @auto_generate false
  defmodule Entity do
    Noizu.V3.CMS.ArticleType.Versioning.versioning_entity() do
      identifier :integer
      internal_field :article
      internal_field :version
      internal_field :editor
      internal_field :status
      internal_field :archive_type
      internal_field :archive
      internal_field :time_stamp, nil, Noizu.Scaffolding.V3.TimeStamp.PersistenceStrategy
    end

    def archive(revision, entity, _context, _options) do
      %__MODULE__{revision| archive_type: :raw, archive: entity}
    end
    def archive!(revision, entity, _context, _options) do
      %__MODULE__{revision| archive_type: :raw, archive: entity}
    end




    def overwrite_field(:time_stamp = field, source, current, _context, options) do
      cond do
        is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
        is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
        modified_on = source[:modified_on] ->
          current && %Noizu.Scaffolding.V3.TimeStamp{current| modified_on: modified_on} || Noizu.Scaffolding.V3.TimeStamp.new(modified_on)
        :else ->
          modified_on = options[:current_time] || DateTime.utc_now()
          current && %Noizu.Scaffolding.V3.TimeStamp{current| modified_on: modified_on} || Noizu.Scaffolding.V3.TimeStamp.new(modified_on)
      end
    end
    def overwrite_field(field, source, current, _context, _options) do
      cond do
        is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
        is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
        :else -> current
      end
    end

    def update_field(:editor = field, source, current, context, options) do
      source[field] || options[:editor] || current || context.caller
    end
    def update_field(:status = field, source, current, context, options) do
      overwrite_field(field, source, current, context, options)
    end
    def update_field(:time_stamp = field, source, current, _context, options) do
      cond do
        is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
        is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
        modified_on = source[:modified_on] ->
          current && %Noizu.Scaffolding.V3.TimeStamp{current| modified_on: modified_on} || Noizu.Scaffolding.V3.TimeStamp.new(modified_on)
        :else ->
          modified_on = options[:current_time] || DateTime.utc_now()
          current && %Noizu.Scaffolding.V3.TimeStamp{current| modified_on: modified_on} || Noizu.Scaffolding.V3.TimeStamp.new(modified_on)
      end
    end
    def update_field(field, source, current, _context, _options) do
      cond do
        current -> current
        is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
        is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
        :else -> nil
      end
    end

    def overwrite!(revision, update, context, options), do: overwrite(revision, update, context, options)
    def overwrite(revision, update, context, options) do
      Enum.reduce(Map.from_struct(revision), revision, fn({field, current}, acc) ->
        put_in(acc, [Access.key(field)], overwrite_field(field, update, current, context, options))
      end)
    end


    def update!(revision, update, context, options), do: update(revision, update, context, options)
    def update(revision, update, context, options) do
      Enum.reduce(Map.from_struct(revision), revision, fn({field, current}, acc) ->
        put_in(acc, [Access.key(field)], update_field(field, update, current, context, options))
      end)
    end




  end

  defmodule Repo do
    Noizu.V3.CMS.ArticleType.Versioning.versioning_repo() do
    end

    def new_revision(entity, context, options) do
      article_info =  Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      article = article_info.article
      rev = case article_info.revision do
              nil -> 0
              {:ref, _, {_version, rev}} -> rev
            end
      revision_identifier = {article_info.version, rev + 1}
      %Noizu.V3.CMS.Version.Revision.Entity{
        identifier: revision_identifier,
        article: article,
        version: article_info.version,
        editor: article_info.editor,
        status: article_info.status,
        archive_type: nil,
        archive: nil,
        time_stamp: article_info.time_stamp,
      }
    end

    def new_revision!(entity, context, options) do
      article_info =  Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      article = article_info.article
      rev = case article_info.revision do
              nil -> 0
              {:ref, _, {_version, rev}} -> rev
            end
      revision_identifier = {article_info.version, rev + 1}
      %Noizu.V3.CMS.Version.Revision.Entity{
        identifier: revision_identifier,
        article: article,
        version: article_info.version,
        editor: article_info.editor,
        status: article_info.status,
        archive_type: nil,
        archive: nil,
        time_stamp: article_info.time_stamp,
      }
    end

  end

end
