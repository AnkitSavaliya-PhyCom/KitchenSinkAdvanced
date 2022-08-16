#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

use Amnesia

defdatabase Noizu.EmailService.V3.Database do

  def database(), do: __MODULE__

  def create_handler(%{__struct__: table} = record, _context, _options) do
    table.write(record)
  end

  def create_handler!(%{__struct__: table} = record, _context, _options) do
    table.write!(record)
  end

  def update_handler(%{__struct__: table} = record, _context, _options) do
    table.write(record)
  end

  def update_handler!(%{__struct__: table} = record, _context, _options) do
    table.write!(record)
  end

  def delete_handler(%{__struct__: table} = record, _context, _options) do
    table.delete(record.identifier)
  end

  def delete_handler!(%{__struct__: table} = record, _context, _options) do
    table.delete!(record.identifier)
  end


  #-----------------------------------------------------------------------------
  # @Email.Template
  #-----------------------------------------------------------------------------
  # 1. Email Template
  deftable Email.Template.Table, [:identifier, :handle, :synched_on, :entity], type: :ordered_set, index: [:handle, :synched_on] do
    @moduledoc """
    Email Template
    """
    @type t :: %Email.Template.Table{
                 identifier: any,
                 handle: nil,
                 synched_on: nil | integer,
                 entity: Noizu.EmailService.V3.Email.TemplateEntity.t
               }

  end # end deftable Email.Templates

  #-----------------------------------------------------------------------------
  # @Email.Queue
  #-----------------------------------------------------------------------------
  # 2. Email Queue
  deftable Email.Queue.Table,
           [:identifier, :recipient, :sender, :state, :created_on, :retry_on, :entity],
           type: :set,
           index: [:recipient, :sender, :state, :created_on, :retry_on] do
    @moduledoc """
    Email Queue
    """
    @type t :: %Email.Queue.Table{
                 identifier: any,
                 recipient: Noizu.KitchenSink.V3.Types.entity_reference,
                 sender: Noizu.KitchenSink.V3.Types.entity_reference,
                 state: :queued | :delivered | :undeliverable | :retrying | :error,
                 created_on: integer,
                 retry_on: nil | integer,
                 entity: Noizu.EmailService.V3.Email.QueueEntity.t
               }
  end # end deftable Email.Queue


  #-----------------------------------------------------------------------------
  # @Email.Queue.Event
  #-----------------------------------------------------------------------------
  deftable Email.Queue.Event.Table,
           [:identifier, :queue_item, :event, :event_time, :entity],
           type: :set,
           index: [:queue_item, :event, :event_time, :entity] do
    @moduledoc """
    Email Queue Event
    """
    @type t :: %Email.Queue.Event.Table{
                 identifier: any,
                 queue_item: any,
                 event: atom, # send, retry, giveup
                 event_time: integer,
                 entity: Noizu.EmailService.V3.Email.Queue.EventEntity.t
               }
  end # end deftable Email.Queue.Event.Table


end
