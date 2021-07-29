#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Version.Revision do
  use Noizu.V3.CMS.ArticleType.Versioning
  @vsn 1.0
  @sref "cms-article-revision"
  @persistence_layer {Noizu.V3.CMS.Database, Noizu.V3.CMS.Database.Article.Version.Revision.Table}
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
