#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Version do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @sref "cms-article-version"
  @persistence_layer {Noizu.V3.CMS.Database, Noizu.V3.CMS.Database.Article.Version.Table}
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

    def new_version(entity, context, options) do
      article_info =  Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      article = article_info.article
      current_version = article_info.version
      version_path = next_version_path(article, article_info.version, context, options)
      version_identifer = {article, version_path}
      %Noizu.V3.CMS.Version.Entity{
        identifier: version_identifer,
        article: article,
        parent: article_info.version,
        editor: article_info.editor,
        status: article_info.status,
        time_stamp: article_info.time_stamp,
      }
    end

    def new_version!(entity, context, options) do
      article_info =  Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      article = article_info.article
      current_version = article_info.version
      version_path = next_version_path!(article, article_info.version, context, options)
      version_identifer = {article, version_path}
      %Noizu.V3.CMS.Version.Entity{
        identifier: version_identifer,
        article: article,
        parent: article_info.version,
        editor: article_info.editor,
        status: article_info.status,
        time_stamp: article_info.time_stamp,
      }
    end

    def version_sequencer(_ref, _context, _optiosm), do: nil
    def version_sequencer!( _ref, _context, _optiosm), do: nil

    def next_version_path(article, version, context, options) do
      cond do
        version == nil -> {version_sequencer({article, {}}, context, options)}
        :else ->
          {:ref, _, {_article, path}} = version
          List.to_tuple(Tuple.to_list(path), m.version_sequencer({article, path}))
      end
    end

    def next_version_path!(article, version, context, options) do
      cond do
        version == nil -> {version_sequencer!({article, {}}, context, options)}
        :else ->
          {:ref, _, {_article, path}} = version
          List.to_tuple(Tuple.to_list(path), version_sequencer!({article, path}))
      end
    end



  end

end
