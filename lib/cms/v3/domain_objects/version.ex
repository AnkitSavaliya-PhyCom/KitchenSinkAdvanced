#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Version do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @sref "cms-article-version"
  @persistence_layer {Noizu.V3.CMS.Database, Noizu.V3.CMS.Article.Version.Table}
  defmodule Entity do
    Noizu.V3.CMS.ArticleType.article_entity() do
      identifier :integer
      internal_field :article
      internal_field :parent
      internal_field :editor
      internal_field :status
      internal_field :time_stamp, nil, Noizu.Scaffolding.V3.TimeStamp.PersistenceStrategy
    end
  end

  defmodule Repo do
    Noizu.V3.CMS.ArticleType.article_repo() do
    end
  end

end
