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
      assert post.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, article_identifier, expected_version_path, expected_revision}}
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
      # 1.-
      expected_1v1_version_path = {1, 1}
      expected_1v1_revision = 1
      post_1v1 = %Noizu.V3.CMS.Article.Post.Entity{post| body: MarkDown.new("[Updated](Content)")}
                 |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      assert post_1v1.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, article_identifier, expected_1v1_version_path, expected_1v1_revision}}
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
      assert post_1v2.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, article_identifier, expected_1v2_version_path, expected_1v2_revision}}
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
      assert post_1v1v1.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, article_identifier, expected_1v1v1_version_path, expected_1v1v1_revision}}
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
      assert post_1v2v1.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, article_identifier, expected_1v2v1_version_path, expected_1v2v1_revision}}
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
  @tag :wip
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
      
      assert post_1v1_rev2.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, article_identifier, {1,1}, 2}}
      assert post_1v1_rev2.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {{:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier}, {1,1}}}
      assert post_1v1_rev2.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post_1v1_rev2.article_info.version, 2}}
      active_revision = Noizu.V3.CMS.Protocol.active_revision!(article, @context, [])
      assert active_revision != nil
      assert active_revision != post_1v1_rev2.article_info.revision
      
      #..........
      # New Revision, on active
      post_rev2 = %Noizu.V3.CMS.Article.Post.Entity{post| body: MarkDown.new("[Updated](Content).rev")}
                  |> Noizu.V3.CMS.Article.CMS.new_revision!(@context, [active: true])
      
      assert post_rev2.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, article_identifier, {1}, 2}}
      assert post_rev2.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {{:ref, Noizu.V3.CMS.Article.Post.Entity, article_identifier}, {1}}}
      assert post_rev2.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post_rev2.article_info.version, 2}}
      active_revision = Noizu.V3.CMS.Protocol.active_revision!(article, @context, [])
      assert active_revision != nil
      assert active_revision == post_rev2.article_info.revision
    end
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Create Should Populate Version, Revision, Index and Tag Tables." do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      
      # Verify Identifier Created
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, _version, _revision}} = post.identifier
      assert is_integer(aid) == true
      assert post.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, {1}, 1}}
      
      # Verify article_info fleshed out.
      article_ref = {:ref, Noizu.V3.CMS.Article.Post.Entity, aid}
      assert post.article_info.article == article_ref
      
      # Verify Created On/Modified On dates.
      assert post.article_info.time_stamp.created_on != nil
      assert post.article_info.time_stamp.modified_on != nil
      
      # Verify Version Info
      assert post.article_info.version == {:ref, Noizu.V3.CMS.Version.Entity, {post.article_info.article, {1}}}
      
      # Verify Parent Info
      assert post.article_info.parent == nil
      
      # Verify Revision
      assert post.article_info.revision == {:ref, Noizu.V3.CMS.Version.Revision.Entity, {post.article_info.version, 1}}
      
      # Verify Type  Set correctly
      assert post.article_info.article_type == :default
      
      # Verify Version Record
      version_key = elem(post.article_info.version, 2)
      version_record = Article.Version.Table.read!(version_key)
      assert version_record.entity.parent == nil
      assert version_record.entity.article == article_ref
      
      # Verify Revision Record
      revision_key = elem(post.article_info.revision, 2)
      revision_record = Article.Version.Revision.Table.read!(revision_key)
      assert revision_record.entity.archive_type == :raw
      assert revision_record.entity.archive != nil
      assert revision_record.entity.article == article_ref
      
      # Verify Active Version and Active Revision Record
      active_version = Article.Active.Version.Table.read!(post.article_info.article)
      assert active_version != nil
      assert active_version.version == post.article_info.version
      
      active_revision = Article.Active.Version.Revision.Table.read!(post.article_info.version)
      assert active_revision != nil
      assert active_revision.revision == post.article_info.revision
      
      # Verify Tags
      tags = Article.Tag.Table.read!(article_ref)
             |> Enum.map(&(&1.tag))
      assert Enum.member?(tags, "apple") == true
      assert Enum.member?(tags, "test") == true
      
      # Verify Index Record
      index_record = Noizu.V3.CMS.Database.Article.Index.Table.read!(article_ref)
      assert index_record.article == {:ref, Noizu.V3.CMS.Article.Post.Entity, aid}
      assert index_record.active_version == post.article_info.version
      assert index_record.created_on == DateTime.to_unix(post.article_info.time_stamp.created_on)
      assert index_record.modified_on == DateTime.to_unix(post.article_info.time_stamp.modified_on)
      assert index_record.manager == Noizu.V3.CMS.Article.Post.Entity
      assert index_record.article_type == :default
      assert index_record.status == :pending
    end
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Updating an active record should cause the Index and Tag table to update as well." do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      revised_post = %Noizu.V3.CMS.Article.Post.Entity{post|
                       title: MarkDown.new("#My Post-2"),
                       body: MarkDown.new("*My Body-2*"),
                       attributes: %{},
                       article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                     } |> Noizu.V3.CMS.Article.Repo.update!(@context)
      
      # Verify Tags
      tags = Article.Tag.Table.read!(revised_post.article_info.article)
             |> Enum.map(&(&1.tag))
      assert Enum.member?(tags, "apple") == false
      assert Enum.member?(tags, "test") == false
      assert Enum.member?(tags, "hello") == true
      assert Enum.member?(tags, "steve") == true
    end
  end
  
  
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Get by entity id." do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      revised_post = %Noizu.V3.CMS.Article.Post.Entity{post|
                       title: MarkDown.new("#My Post-2"),
                       body: MarkDown.new("*My Body-2*"),
                       attributes: %{},
                       article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                     } |> Noizu.V3.CMS.Article.Repo.update!(@context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, id, _version_path, _revision}} = revised_post.identifier
      r = Noizu.V3.CMS.Article.Repo.get!(id, @context)
      assert r.identifier == revised_post.identifier
    end
  end
  
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Get by entity version." do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      revised_post = %Noizu.V3.CMS.Article.Post.Entity{post|
                       title: MarkDown.new("#My Post-2"),
                       body: MarkDown.new("*My Body-2*"),
                       attributes: %{},
                       article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                     } |> Noizu.V3.CMS.Article.Repo.update!(@context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, id, version_path, _revision}} = revised_post.identifier
      r = Noizu.V3.CMS.Article.Repo.get!({:version, {Noizu.V3.CMS.Article.Post.Entity, id, version_path}}, @context)
      assert r.identifier == revised_post.identifier
    end
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - User should be able to create new revisions." do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, _version, _revision}} = post.identifier
      post_v2 = %Noizu.V3.CMS.Article.Post.Entity{post|
                  title: MarkDown.new("#My Post-2"),
                  body: MarkDown.new("*My Body-2*"),
                  attributes: %{},
                  article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                } |> Noizu.V3.CMS.Article.CMS.new_revision!(@context)
      
      # Verify New Revision Created.
      revision_key = elem(post_v2.article_info.revision, 2)
      revision_record = Article.Version.Revision.Table.read!(revision_key)
      assert revision_record.status == :approved
      assert revision_record.identifier ==  {{:ref, Noizu.V3.CMS.Version.Entity, {post.article_info.article, {1}}}, 2}
      
      
      # Verify Version Correct in post_v2
      assert post_v2.article_info.version == post.article_info.version
      assert post_v2.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, {1}, 2}}
      
      # Verify Index Not Updated
      index_record = Noizu.V3.CMS.Database.Article.Index.Table.read!(post.article_info.article)
      assert index_record.status != :approved
      
      # Verify Tags
      tags = Article.Tag.Table.read!(post.article_info.article)
             |> Enum.map(&(&1.tag))
      assert Enum.member?(tags, "apple") == true
      assert Enum.member?(tags, "test") == true
      assert Enum.member?(tags, "hello") == false
      assert Enum.member?(tags, "steve") == false
    end
  end
  
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - User should be able to create new versions." do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, _version, _revision}} = post.identifier
      post_v2 = %Noizu.V3.CMS.Article.Post.Entity{post|
                  title: MarkDown.new("#My Post-2"),
                  body: MarkDown.new("*My Body-2*"),
                  attributes: %{},
                  article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      
      # Verify New Revision Created.
      revision_key = elem(post_v2.article_info.revision, 2)
      revision_record = Article.Version.Revision.Table.read!(revision_key)
      assert revision_record.status == :approved
      assert revision_record.identifier ==  {{:ref, Noizu.V3.CMS.Version.Entity, {post.article_info.article, {1,1}}}, 1}
      
      
      # Verify Version Correct in post_v2
      assert post_v2.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, {1,1}, 1}}
      
      # Verify Index Not Updated
      index_record = Noizu.V3.CMS.Database.Article.Index.Table.read!(post.article_info.article)
      assert index_record.status != :approved
      
      # Verify Tags
      tags = Article.Tag.Table.read!(post.article_info.article)
             |> Enum.map(&(&1.tag))
      assert Enum.member?(tags, "apple") == true
      assert Enum.member?(tags, "test") == true
      assert Enum.member?(tags, "hello") == false
      assert Enum.member?(tags, "steve") == false
    end
  end
  
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - User should be able to create multiple versions based on a single parent." do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, _version, _revision}} = post.identifier
      post_v2 = %Noizu.V3.CMS.Article.Post.Entity{post|
                  title: MarkDown.new("#My Post-2"),
                  body: MarkDown.new("*My Body-2*"),
                  attributes: %{},
                  article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      post_v3 = %Noizu.V3.CMS.Article.Post.Entity{post|
                  title: MarkDown.new("#My Post-3"),
                  body: MarkDown.new("*My Body-3*"),
                  attributes: %{},
                  article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      post_v4 = %Noizu.V3.CMS.Article.Post.Entity{post|
                  title: MarkDown.new("#My Post-4"),
                  body: MarkDown.new("*My Body-4*"),
                  attributes: %{},
                  article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      
      # Verify New Revision Created.
      revision_key = elem(post_v2.article_info.revision, 2)
      revision_record = Article.Version.Revision.Table.read!(revision_key)
      assert revision_record.status == :approved
      assert revision_record.identifier ==  {{:ref, Noizu.V3.CMS.Version.Entity, {post.article_info.article, {1,1}}}, 1}
      
      
      # Verify Version Correct
      assert post_v2.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, {1,1}, 1}}
      assert post_v3.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, {1,2}, 1}}
      assert post_v4.identifier == {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, {1,3}, 1}}
      
      # Verify Index Not Updated
      index_record = Noizu.V3.CMS.Database.Article.Index.Table.read!(post.article_info.article)
      assert index_record.status != :approved
      
      # Verify Tags
      tags = Article.Tag.Table.read!(post.article_info.article)
             |> Enum.map(&(&1.tag))
      assert Enum.member?(tags, "apple") == true
      assert Enum.member?(tags, "test") == true
      assert Enum.member?(tags, "hello") == false
      assert Enum.member?(tags, "steve") == false
    end
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Delete Active Revision" do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, _aid, _version, _revision}} = post.identifier
      _post_v2 = %Noizu.V3.CMS.Article.Post.Entity{post|
                   title: MarkDown.new("#My Post-2"),
                   body: MarkDown.new("*My Body-2*"),
                   attributes: %{},
                   article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                 } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      _post_v3 = %Noizu.V3.CMS.Article.Post.Entity{post|
                   title: MarkDown.new("#My Post-3"),
                   body: MarkDown.new("*My Body-3*"),
                   attributes: %{},
                   article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                 } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      _post_v4 = %Noizu.V3.CMS.Article.Post.Entity{post|
                   title: MarkDown.new("#My Post-4"),
                   body: MarkDown.new("*My Body-4*"),
                   attributes: %{},
                   article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                 } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      
      expected_throw = try do
                         Noizu.V3.CMS.Article.Repo.delete!(post.identifier, @context)
      catch expected_throw -> expected_throw
                       end
      assert expected_throw == :active_revision
    end
  end
  
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Delete Active Version" do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, _aid, _version, _revision}} = post.identifier
      post_rev2 = %Noizu.V3.CMS.Article.Post.Entity{post|
                    title: MarkDown.new("#My Post-2"),
                    body: MarkDown.new("*My Body-2*"),
                    attributes: %{},
                    article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                  } |> Noizu.V3.CMS.Article.CMS.new_revision!(@context)
      _post_v3 = %Noizu.V3.CMS.Article.Post.Entity{post|
                   title: MarkDown.new("#My Post-3"),
                   body: MarkDown.new("*My Body-3*"),
                   attributes: %{},
                   article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                 } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      _post_v4 = %Noizu.V3.CMS.Article.Post.Entity{post|
                   title: MarkDown.new("#My Post-4"),
                   body: MarkDown.new("*My Body-4*"),
                   attributes: %{},
                   article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                 } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      Noizu.V3.CMS.Article.Repo.delete!(post_rev2.identifier, @context)
    end
  end
  
  
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Delete Version Active Revision" do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, _aid, _version, _revision}} = post.identifier
      _post_rev2 = %Noizu.V3.CMS.Article.Post.Entity{post|
                     title: MarkDown.new("#My Post-2"),
                     body: MarkDown.new("*My Body-2*"),
                     attributes: %{},
                     article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                   } |> Noizu.V3.CMS.Article.CMS.new_revision!(@context)
      post_v3 = %Noizu.V3.CMS.Article.Post.Entity{post|
                  title: MarkDown.new("#My Post-3"),
                  body: MarkDown.new("*My Body-3*"),
                  attributes: %{},
                  article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      _post_v4 = %Noizu.V3.CMS.Article.Post.Entity{post|
                   title: MarkDown.new("#My Post-4"),
                   body: MarkDown.new("*My Body-4*"),
                   attributes: %{},
                   article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                 } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      expected_throw = try do
                         Noizu.V3.CMS.Article.Repo.delete!(post_v3.identifier, @context)
      catch expected_throw -> expected_throw
                       end
      assert expected_throw == :version_active_revision
    end
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Delete Inactive Version" do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, _aid, _version, _revision}} = post.identifier
      _post_rev2 = %Noizu.V3.CMS.Article.Post.Entity{post|
                     title: MarkDown.new("#My Post-2"),
                     body: MarkDown.new("*My Body-2*"),
                     attributes: %{},
                     article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                   } |> Noizu.V3.CMS.Article.CMS.new_revision!(@context)
      post_v3 = %Noizu.V3.CMS.Article.Post.Entity{post|
                  title: MarkDown.new("#My Post-3"),
                  body: MarkDown.new("*My Body-3*"),
                  attributes: %{},
                  article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      post_v3_rev2 = %Noizu.V3.CMS.Article.Post.Entity{post_v3|
                       title: MarkDown.new("#My Post-3"),
                       body: MarkDown.new("*My Body-3*"),
                       attributes: %{},
                       article_info: %Noizu.V3.CMS.Article.Info{post_v3.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                     } |> Noizu.V3.CMS.Article.CMS.new_revision!(@context)
      _post_v4 = %Noizu.V3.CMS.Article.Post.Entity{post|
                   title: MarkDown.new("#My Post-4"),
                   body: MarkDown.new("*My Body-4*"),
                   attributes: %{},
                   article_info: %Noizu.V3.CMS.Article.Info{post.article_info| tags: MapSet.new(["hello", "steve"]), status: :approved}
                 } |> Noizu.V3.CMS.Article.CMS.new_version!(@context)
      Noizu.V3.CMS.Article.Repo.delete!(post_v3_rev2.identifier, @context)
    end
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Expand Revision Ref" do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      post_ref = Noizu.ERP.ref(post)
      sut = Noizu.V3.CMS.Article.Entity.entity!(post_ref)
      assert sut.identifier == post.identifier
    end
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Expand Version Ref" do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      {:revision, {type, aid, version, _revision}} = post.identifier
      version_ref = {:ref, Noizu.V3.CMS.Article.Post.Entity, {:version, {type, aid, version}}}
      sut = Noizu.V3.CMS.Article.Entity.entity!(version_ref)
      assert sut.identifier == post.identifier
    end
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Expand Bare Ref" do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      sut = Noizu.V3.CMS.Article.Entity.entity!(post.article_info.article)
      assert sut.identifier == post.identifier
    end
  end
  
  
  @tag :cms
  @tag :cms_v3
  @tag :cms_built_in
  test "Article - Sref" do
    with_mocks([
      {Article.Table, [:passthrough], MockDB.Article.MockTable.config()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.config()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.config()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.config()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.config()},
      {Article.Version.Revision.Table, [:passthrough], MockDB.Article.Version.Revision.MockTable.config()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.config()},
      {Article.Active.Version.Revision.Table, [:passthrough], MockDB.Article.Active.Version.Revision.MockTable.config()},
    ]) do
      Noizu.Testing.Mnesia.Emulator.reset()
      
      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)
      {:revision, {Noizu.V3.CMS.Article.Post.Entity, aid, _version, _revision}} = post.identifier
      sref = Noizu.V3.CMS.Article.Entity.sref(post)
      assert sref == "ref.cms.{#{aid}-post@1-1}"
    end
  end
  
  
  @tag :cms
  @tag :cms_v3
  test "Extended ERP Revision Support - sref to ref happy path" do
    ref = Noizu.V3.CMS.Article.Entity.ref("ref.cms.{1234-post@1.2.1-432}")
    assert ref == {:ref, Noizu.V3.CMS.Article.Post.Entity, {:revision, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1,2,1}, 432}}}
    
    ref = Noizu.V3.CMS.Article.Entity.ref("ref.cms.{1234-post}")
    assert ref == {:ref, Noizu.V3.CMS.Article.Post.Entity, 1234}
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :wip
  test "Extended ERP Revision Support - negative cases" do
    # improperly formatted
    ref = Noizu.V3.CMS.Article.Post.Entity.ref("ref.cms.{1234-post@1.2-.1-432}")
    assert ref == nil
    
    # invalid ref
    ref = Noizu.V3.CMS.Article.Post.Entity.ref("ef.cms.{1234-post@1.2.1}")
    assert ref == nil
    
    # root path
    ref = Noizu.V3.CMS.Article.Post.Entity.ref("ref.cms.{1234-post@1-2}")
    assert ref == {:ref, Noizu.V3.CMS.Article.Post.Entity, {:revision, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1}, 2}}}
    
    # blank revision
    ref = Noizu.V3.CMS.Article.Post.Entity.ref("ref.cms.{1234-post@1-}")
    assert ref == nil
    
    # blank path
    ref = Noizu.V3.CMS.Article.Post.Entity.ref("ref.cms.{1234-post@-5}")
    assert ref == nil
    
    # blank identifier
    ref = Noizu.V3.CMS.Article.Post.Entity.ref("ref.cms.{@1.2.3-5}")
    assert ref == nil
  end
  
  @tag :cms
  @tag :cms_v3
  test "Extended ERP Revision Support - ref to sref happy path" do
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1, 2, 1}, 432}}})
    assert sref == "ref.cms.{1234-post@1.2.1-432}"
    
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1, 2, 1}, "apple"}}})
    assert sref == "ref.cms.{1234-post@1.2.1-apple}"
    
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1, 2, 1}}}})
    assert sref == "ref.cms.{1234-post@1.2.1}"
    
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1, 2, "Tiger"}}}})
    assert sref == "ref.cms.{1234-post@1.2.Tiger}"
    
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, 1234})
    assert sref == "ref.cms.{1234-post}"
  end
  
  @tag :cms
  @tag :cms_v3
  @tag :wip
  test "Extended ERP Revision Support - ref to sref negative cases" do
    # Invalid identifier
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:unsupported, {1234, {1, 2, 1}, 432}}})
    assert sref == nil
    
    # Blank identifier
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {Noizu.V3.CMS.Article.Post.Entity, nil, {1, 2, 1}, 432}}})
    assert sref == nil
    
    # Nil path entry
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1, nil, 1}, 432}}})
    assert sref == nil
    
    # Nil path
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {Noizu.V3.CMS.Article.Post.Entity, 1234, nil, 432}}})
    assert sref == nil
    
    # Empty path
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {Noizu.V3.CMS.Article.Post.Entity, 1234, {}, 432}}})
    assert sref == nil
    
    # Invalid Path (contains '-')
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1,2,-5}}}})
    assert sref == nil
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1,2,"-5"}}}})
    assert sref == nil
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {Noizu.V3.CMS.Article.Post.Entity, 1234, {1,2,:"-5"}}}})
    assert sref == nil
    
    # Version - Blank identifier
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {nil, {1, 2, 1}}}})
    assert sref == nil
    
    # Version - Nil path entry
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {1234, {1, nil, 1}}}})
    assert sref == nil
    
    # Version - Nil path
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {1234, nil}}})
    assert sref == nil
    
    #  Version - Empty path
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {1234, {}}}})
    assert sref == nil
    
    #  Version - Invalid Path (contains '-')
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {1234, {1,2,-5}}}})
    assert sref == nil
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {1234, {1,2,"-5"}}}})
    assert sref == nil
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:version, {1234, {1,2,:"-5"}}}})
    assert sref == nil
    
    
    # Nil Revision
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {1234, {1}, nil}}})
    assert sref == nil
    
    # Invalid Revision
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {1234, {1}, {1}}}})
    assert sref == nil
    
    # Invalid Revision
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {1234, {1}, [1]}}})
    assert sref == nil
    
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {1234, {1}, "1234-1234"}}})
    assert sref == nil
    
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {1234, {1}, -1234}}})
    assert sref == nil
    
    sref = Noizu.V3.CMS.Article.Post.Entity.sref({:ref, Noizu.V3.CMS.Article.Entity, {:revision, {1234, {1}, :"1234@1234"}}})
    assert sref == nil
  
  end




end
