#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.Testing.ChangeSet do
  alias Noizu.MnesiaVersioning.ChangeSet
  use Amnesia
  use Noizu.V3.Testing.Database
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
        changeset:  "Fixture Management",
        author: "Keith Brings",
        note: "",
        environments: [:test, :feature, :dev, :stage],
        update: fn() ->
                  neighbors = neighbors()
                  create_table(Database.Fixture.Table, [disk: neighbors])
                  create_table(Database.Fixture.History.Table, [disk: neighbors])
                  :success
        end,
        rollback: fn() ->
          destroy_table(Database.Fixture.Table)
          destroy_table(Database.Fixture.History.Table)
          :removed
        end
      }
    ]
  end
end
