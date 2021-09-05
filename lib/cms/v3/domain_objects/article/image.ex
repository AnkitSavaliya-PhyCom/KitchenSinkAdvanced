#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Article.Image do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @poly_base Noizu.V3.CMS.Article
  # this is a defect we should be able to rely on the poly base persistence settings but because the ArticleType using macro injects the persistence layer the fallback logic is bypassed.
  @persistence_layer {Noizu.V3.CMS.Database, Noizu.V3.CMS.Database.Article.Table, cascade?: true, cascade_block?: true}
  defmodule Entity do
    Noizu.V3.CMS.ArticleType.article_entity() do
      identifier :compound

      public_field :title
      public_field :alt
      public_field :resolution
      public_field :image

      internal_field :attributes
      internal_field :article_info
      internal_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
    def sref_subtype(), do: "image"
  end
end
