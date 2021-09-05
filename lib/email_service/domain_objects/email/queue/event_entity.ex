#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2020 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.EmailService.V3.Email.Queue.Event do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "queued-email-event"
  @persistence_layer {Noizu.EmailService.V3.Database, cascade_block?: true, table: Noizu.EmailService.V3.Database.Email.Queue.Event.Table}
  defmodule Entity do
    @universal_identifier false
    Noizu.DomainObject.noizu_entity() do
      identifier :integer
      public_field :queue_item
      public_field :event
      public_field :event_time, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
      public_field :details, %{}
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo() do
    end
  end

end
