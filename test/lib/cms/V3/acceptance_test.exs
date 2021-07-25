#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2019 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.AcceptanceTest do
  use ExUnit.Case, async: false
  use Amnesia
  use Noizu.V3.CMS.Database

  #----------------
  # Import
  #----------------
  import Mock

  #----------------
  # Require
  #----------------
  require Logger

  #----------------
  # Aliases
  #----------------
  alias Noizu.V3.CMS.Database.Article
  alias Noizu.Support.V3.CMS.Database, as: MockDB
  alias Noizu.V3.CMS.MarkdownField, as: MarkDown

  #----------------
  # Macros
  #----------------
  @context Noizu.ElixirCore.CallingContext.system()
  @cms_post  %Noizu.V3.CMS.Article.Post.Entity{
    title: %MarkDown{markdown: "My Post"},
    body: %MarkDown{markdown: "My Post Contents"},
    attributes: %{},
    article_info: %Noizu.V3.CMS.Article.Info{tags: MapSet.new(["test", "apple"])}
  }

  #==============================================
  # Acceptance Tests
  #==============================================

  #----------------------------------------
  # Default Version Provider
  #----------------------------------------
  @tag :cms
  @tag :cms_v3
  @tag :cms_version_provider
  test "Create Version" do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()

      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      post2 = Noizu.V3.CMS.Article.Repo.get!(post.identifier, @context)
      IO.puts """




  #{inspect post}
  +++++++++++++++
  #{inspect post2}



"""
      article = post.article_info.article
      {:ref, _, aid} = article

      # Verify article
      #assert post.identifier == {:revision, {aid, {1}, 1}}

      # Verify Version Info
      #assert post.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {post.article_info.article, {1}}}

      # Create new Versions
      #post_1v1 = %Noizu.V3.CMS.Article.Post.Entity{post| body: %Noizu.MarkdownField{markdown: "My Updated Contents 1"}} |> Noizu.V3.CMS.Article.CMS.Version.new!(@context)
      #post_1v2 = %Noizu.V3.CMS.Article.Post.Entity{post| body: %Noizu.MarkdownField{markdown: "My Updated Contents 2"}} |> Noizu.V3.CMS.Article.CMS.Version.new!(@context)
      #post_1v1v1 = %Noizu.V3.CMS.Article.Post.Entity{post_1v1| body: %Noizu.MarkdownField{markdown: "My Updated Contents 3"}} |> Noizu.V3.CMS.Article.CMS.Version.new!(@context)
      #post_1v2v1 = %Noizu.V3.CMS.Article.Post.Entity{post_1v2| body: %Noizu.MarkdownField{markdown: "My Updated Contents 4"}} |> Noizu.V3.CMS.Article.CMS.Version.new!(@context)

      # Verify Version Info
      #assert post_1v1.article_info.version == {:ref, Noizu.V3.CMS.VersionEntity, {article, {1,1}}}
      #assert post_1v2.article_info.version == {:ref, Noizu.V3.CMS.VersionEntity, {article, {1,2}}}
      #assert post_1v1v1.article_info.version == {:ref, Noizu.V3.CMS.VersionEntity, {article, {1,1,1}}}
      #assert post_1v2v1.article_info.version == {:ref, Noizu.V3.CMS.VersionEntity, {article, {1,2,1}}}

      # Verify Identifiers
      #assert post_1v1.identifier == {:revision, {aid, {1,1}, 1}}
      #assert post_1v2.identifier == {:revision, {aid, {1,2}, 1}}
      #assert post_1v1v1.identifier == {:revision, {aid, {1,1,1}, 1}}
      #assert post_1v2v1.identifier == {:revision, {aid, {1,2,1}, 1}}

    end
  end

end
