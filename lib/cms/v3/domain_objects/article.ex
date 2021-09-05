#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Article do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @sref "cms"
  @poly_support [Noizu.V3.CMS.Article, Noizu.V3.CMS.Article.File, Noizu.V3.CMS.Article.Image, Noizu.V3.CMS.Article.Post]
  @poly_base Noizu.V3.CMS.Article
  @persistence_layer {Noizu.V3.CMS.Database, Noizu.V3.CMS.Database.Article.Table, cascade?: true, cascade_block?: true}
  defmodule Entity do
    Noizu.V3.CMS.ArticleType.article_entity() do
      identifier :compound

      public_field :title
      public_field :body
      internal_field :attributes

      internal_field :article_info
      internal_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    def sref_subtype(), do: "article"

  end

  defmodule Repo do
    Noizu.V3.CMS.ArticleType.article_repo() do
    end
  end

  defmodule CMS do
    Noizu.V3.CMS.ArticleType.article_cms_manager() do
    end

    def sref_subtype_module("article"), do: Noizu.V3.CMS.Article.Entity
    def sref_subtype_module("post"), do: Noizu.V3.CMS.Article.Post.Entity
    def sref_subtype_module("file"), do: Noizu.V3.CMS.Article.File.Entity
    def sref_subtype_module("image"), do: Noizu.V3.CMS.Article.Image.Entity

  end

end
