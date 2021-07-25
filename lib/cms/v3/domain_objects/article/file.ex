#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Article.File do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @poly_base Noizu.V3.CMS.Article
  # this is a defect we should be able to rely on the poly base persistence settings but because the ArticleType using macro injects the persistence layer the fallback logic is bypassed.
  @persistence_layer {Noizu.V3.CMS.Database, Noizu.V3.CMS.Database.Article.Table, cascade?: true, cascade_block?: true}
  defmodule Entity do
    Noizu.V3.CMS.ArticleType.article_entity() do
      identifier :integer

      public_field :title
      public_field :alt
      public_field :description
      public_field :file

      internal_field :article_info
      internal_field :time_stamp, nil, Noizu.Scaffolding.V3.TimeStamp.PersistenceStrategy
    end
  end
end
