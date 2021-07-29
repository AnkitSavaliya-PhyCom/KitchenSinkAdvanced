#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.ChangeSet do
  alias Noizu.MnesiaVersioning.ChangeSet
  use Amnesia
  use Noizu.V3.CMS.Database
  use Noizu.MnesiaVersioning.SchemaBehaviour

  def neighbors() do
    topology_provider = Application.get_env(:noizu_mnesia_versioning, :topology_provider)
    {:ok, nodes} = topology_provider.mnesia_nodes();
    nodes
  end
  #-----------------------------------------------------------------------------
  # ChangeSets
  #-----------------------------------------------------------------------------
  def change_sets do
    [
      %ChangeSet{
        changeset:  "CMS V3 Schema",
        author: "Keith Brings",
        note: "",
        environments: :all,
        update: fn() ->
                  neighbors = neighbors()
                  create_table(Noizu.V3.CMS.Database.Article.Table, [disk: neighbors])
                  create_table(Noizu.V3.CMS.Database.Article.Index.Table, [disk: neighbors])
                  create_table(Noizu.V3.CMS.Database.Article.Tag.Table, [disk: neighbors])
                  create_table(Noizu.V3.CMS.Database.Article.VersionSequencer.Table, [disk: neighbors])
                  create_table(Noizu.V3.CMS.Database.Article.Version.Table, [disk: neighbors])
                  create_table(Noizu.V3.CMS.Database.Article.Version.Revision.Table, [disk: neighbors])
                  create_table(Noizu.V3.CMS.Database.Article.Active.Version.Table, [disk: neighbors])
                  create_table(Noizu.V3.CMS.Database.Article.Active.Version.Revision.Table, [disk: neighbors])
                  :success
        end,
        rollback: fn() ->
          destroy_table(Noizu.V3.CMS.Database.Article.Table)
          destroy_table(Noizu.V3.CMS.Database.Article.Index.Table)
          destroy_table(Noizu.V3.CMS.Database.Article.Tag.Table)
          destroy_table(Noizu.V3.CMS.Database.Article.VersionSequencer.Table)
          destroy_table(Noizu.V3.CMS.Database.Article.Version.Table)
          destroy_table(Noizu.V3.CMS.Database.Article.Version.Revision.Table)
          destroy_table(Noizu.V3.CMS.Database.Article.Active.Version.Table)
          destroy_table(Noizu.V3.CMS.Database.Article.Active.Version.Revision.Table)
          :removed
        end
      }
    ]
  end
end
