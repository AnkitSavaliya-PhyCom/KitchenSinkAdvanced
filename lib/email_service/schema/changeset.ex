#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.EmailService.V3.ChangeSet do
  alias Noizu.MnesiaVersioning.ChangeSet
  use Amnesia
  use Noizu.EmailService.V3.Database
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
        changeset:  "Email Service Related Schema",
        author: "Keith Brings",
        note: "You may specify your own tables and override persistence layer in the settings. ",
        environments: :all,
        update: fn() ->
                  neighbors = neighbors()
                  create_table(Noizu.EmailService.V3.Database.Email.Template.Table, [disk: neighbors])
                  create_table(Noizu.EmailService.V3.Database.Email.Queue.Table, [disk: neighbors])
                  :success
        end,
        rollback: fn() ->
          destroy_table(Noizu.EmailService.V3.Database.Email.Template.Table)
          destroy_table(Noizu.EmailService.V3.Database.Email.Queue.Table)
          :removed
        end
      },
      %ChangeSet{
        changeset:  "Email Queue - Queued Email Event History",
        author: "Keith Brings",
        note: "Table for tracking send, resend, etc. attempts.",
        environments: :all,
        update: fn() ->
                  neighbors = neighbors()
                  create_table(Noizu.EmailService.V3.Database.Email.Queue.Event.Table, [disk: neighbors])
                  :success
        end,
        rollback: fn() ->
          destroy_table(Noizu.EmailService.V3.Database.Email.Queue.Event.Table)
          :removed
        end
      }
    ]
  end
end
