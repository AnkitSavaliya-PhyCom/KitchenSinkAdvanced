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
    title: MarkDown.new("#My Post"),
    body: MarkDown.new("*My Body*"),
    attributes: %{},
    #article_info: %Noizu.V3.CMS.Article.Info{tags: MapSet.new(["test", "apple"])}
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
      article = {:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier} = post.article_info.article
      expected_revision = 1
      expected_version_path = {1}
      assert post.identifier == {:revision, {article_identifier, expected_version_path, expected_revision}}
      assert post.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {{:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier}, expected_version_path}}
      assert post.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post.article_info.version, expected_revision}}

      assert post.body.markdown == "*My Body*"
      assert post.body.html == "<p><em>My Body</em></p>\n"

      assert post.title.markdown == "#My Post"
      assert post.title.html == "<h1>My Post</h1>\n"



    end
  end

end
