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
  test "V3.CMS: Create Article and Article Version" do
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

      #.................
      # Verify Related Types.
      #.................

      # Version
      version = Noizu.ERP.entity!(post.article_info.version)
      assert version != nil
      assert version.article == article
      assert version.parent == nil
      assert version.editor == post.article_info.editor
      assert version.status == :pending
      assert version.identifier == {article, expected_version_path}

      # Revision
      revision = Noizu.ERP.entity!(post.article_info.revision)
      assert revision != nil
      assert revision.identifier == {post.article_info.version, expected_revision}
      assert revision.article == article
      assert revision.version == post.article_info.version
      assert revision.editor == post.article_info.editor
      assert revision.status == :pending
      assert revision.archive_type == :raw
      assert revision.archive == post

      # Active Revision
      active_revision = Noizu.V3.CMS.Protocol.active_revision!(article, @context, [])
      assert active_revision != nil
      assert active_revision == post.article_info.revision

      # Tags
      # ... pending

      # Indexes
      # ... pending


      #-------------------------------------------
      # Create Versions
      #-------------------------------------------

      #..........
      # 1.1
      expected_1v1_version_path = {1, 1}
      expected_1v1_revision = 1
      post_1v1 = %Noizu.V3.CMS.Article.Post.Entity{post| body: MarkDown.new("[Updated](Content)")}
                 |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      assert post_1v1.identifier == {:revision, {article_identifier, expected_1v1_version_path, expected_1v1_revision}}
      assert post_1v1.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {{:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier}, expected_1v1_version_path}}
      assert post_1v1.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post_1v1.article_info.version, expected_1v1_revision}}
      active_revision = Noizu.V3.CMS.Protocol.active_revision!(article, @context, [])
      assert active_revision != nil
      assert active_revision != post_1v1.article_info.revision

      #...........
      # 1.2
      expected_1v2_version_path = {1, 2}
      expected_1v2_revision = 1
      post_1v2 = %Noizu.V3.CMS.Article.Post.Entity{post| body: MarkDown.new("[Updated](Content):2")}
                 |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      assert post_1v2.identifier == {:revision, {article_identifier, expected_1v2_version_path, expected_1v2_revision}}
      assert post_1v2.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {{:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier}, expected_1v2_version_path}}
      assert post_1v2.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post_1v2.article_info.version, expected_1v2_revision}}
      active_revision = Noizu.V3.CMS.Protocol.active_revision!(article, @context, [])
      assert active_revision != nil
      assert active_revision != post_1v2.article_info.revision

      #.................
      # 1.1.1
      expected_1v1v1_version_path = {1, 1, 1}
      expected_1v1v1_revision = 1
      post_1v1v1 = %Noizu.V3.CMS.Article.Post.Entity{post_1v1| body: MarkDown.new("[Updated](Content):1.1.1")}
                 |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      assert post_1v1v1.identifier == {:revision, {article_identifier, expected_1v1v1_version_path, expected_1v1v1_revision}}
      assert post_1v1v1.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {{:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier}, expected_1v1v1_version_path}}
      assert post_1v1v1.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post_1v1v1.article_info.version, expected_1v1v1_revision}}
      active_revision = Noizu.V3.CMS.Protocol.active_revision!(article, @context, [])
      assert active_revision != nil
      assert active_revision != post_1v1v1.article_info.revision

      #.................
      # 1.2.1
      expected_1v2v1_version_path = {1, 2, 1}
      expected_1v2v1_revision = 1
      post_1v2v1 = %Noizu.V3.CMS.Article.Post.Entity{post_1v2| body: MarkDown.new("[Updated](Content):1.2.1")}
                   |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      assert post_1v2v1.identifier == {:revision, {article_identifier, expected_1v2v1_version_path, expected_1v2v1_revision}}
      assert post_1v2v1.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {{:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier}, expected_1v2v1_version_path}}
      assert post_1v2v1.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post_1v2v1.article_info.version, expected_1v2v1_revision}}
      active_revision = Noizu.V3.CMS.Protocol.active_revision!(article, @context, [])
      assert active_revision != nil
      assert active_revision != post_1v2v1.article_info.revision
    end
  end


  @tag :cms
  @tag :cms_v3
  @tag :cms_version_provider
  test "V3.CMS: Create Revisions" do
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
      post_1v1 = %Noizu.V3.CMS.Article.Post.Entity{post| body: MarkDown.new("[Updated](Content)")}
                 |> Noizu.V3.CMS.Article.CMS.new_version!(@context)

      #..........
      # New Revision, non active
      post_1v1_rev2 = %Noizu.V3.CMS.Article.Post.Entity{post_1v1| body: MarkDown.new("[Updated](Content).rev")}
                      |> Noizu.V3.CMS.Article.CMS.new_revision!(@context)

      assert post_1v1_rev2.identifier == {:revision, {article_identifier, {1,1}, 2}}
      assert post_1v1_rev2.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {{:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier}, {1,1}}}
      assert post_1v1_rev2.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post_1v1_rev2.article_info.version, 2}}
      active_revision = Noizu.V3.CMS.Protocol.active_revision!(article, @context, [])
      assert active_revision != nil
      assert active_revision != post_1v1_rev2.article_info.revision

      #..........
      # New Revision, on active
      post_rev2 = %Noizu.V3.CMS.Article.Post.Entity{post| body: MarkDown.new("[Updated](Content).rev")}
                      |> Noizu.V3.CMS.Article.CMS.new_revision!(@context)

      assert post_rev2.identifier == {:revision, {article_identifier, {1}, 2}}
      assert post_rev2.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {{:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier}, {1}}}
      assert post_rev2.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post_rev2.article_info.version, 2}}
      active_revision = Noizu.V3.CMS.Protocol.active_revision!(article, @context, [])
      assert active_revision != nil
      assert active_revision == post_rev2.article_info.revision

    end
  end

end
