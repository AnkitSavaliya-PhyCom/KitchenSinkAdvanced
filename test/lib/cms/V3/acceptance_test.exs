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
      {Article.Table, [:passthrough], MockDB.Article.MockTable.strategy()},
      {Article.Index.Table, [:passthrough], MockDB.Article.Index.MockTable.strategy()},
      {Article.Tag.Table, [:passthrough], MockDB.Article.Tag.MockTable.strategy()},
      {Article.VersionSequencer.Table, [:passthrough], MockDB.Article.VersionSequencer.MockTable.strategy()},
      {Article.Version.Table, [:passthrough], MockDB.Article.Version.MockTable.strategy()},
      {Article.Revision.Table, [:passthrough], MockDB.Article.Revision.MockTable.strategy()},
      {Article.Active.Version.Table, [:passthrough], MockDB.Article.Active.Version.MockTable.strategy()},
    ]) do
      Noizu.Support.V3.CMS.Database.MnesiaEmulator.reset()

      # Setup Article
      post = @cms_post
      post = Noizu.V3.CMS.Article.Repo.create!(post, @context)

      IO.inspect post, pretty: true, limit: :infinity
    end
  end

end
