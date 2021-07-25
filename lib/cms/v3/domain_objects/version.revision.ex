#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Version.Revision do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @sref "cms-article-revision"
  @persistence_layer {Noizu.V3.CMS.Database, Noizu.V3.CMS.Database.Article.Version.Revision.Table}
  defmodule Entity do
    Noizu.V3.CMS.ArticleType.article_entity() do
      identifier :integer
      internal_field :article
      internal_field :version
      internal_field :editor
      internal_field :status
      internal_field :archive_type
      internal_field :archive
      internal_field :time_stamp, nil, Noizu.Scaffolding.V3.TimeStamp.PersistenceStrategy
    end
  end

  defmodule Repo do
    Noizu.V3.CMS.ArticleType.article_repo() do
    end
  end

end
