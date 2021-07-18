#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Article.Info do
  use Noizu.SimpleObject
  @vsn 1.0
  Noizu.SimpleObject.noizu_struct() do
    internal_field :article
    internal_field :article_type
    internal_field :manager

    internal_field :name
    internal_field :description
    internal_field :note

    internal_field :parent
    internal_field :version
    internal_field :revision

    internal_field :tags
    internal_field :editor
    internal_field :status

    internal_field :time_stamp, nil, Noizu.Scaffolding.V3.TimeStamp.PersistenceStrategy
  end
end
