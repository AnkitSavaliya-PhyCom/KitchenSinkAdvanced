#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2019 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

use Amnesia
defdatabase Noizu.V3.Testing.Database do

  def database(), do: Noizu.V3.Testing.Database

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
  # @Fixture.Table
  #-----------------------------------------------------------------------------
  deftable Fixture.Table, [:identifier, :type, :check_out, :flagged, :owner_pid, :entity], type: :set, index: [:type, :check_out, :flag, :owner_pid] do
    @type t :: %__MODULE__{
                 identifier: tuple,
                 type: atom,
                 check_out: tuple,
                 flagged: boolean,
                 owner_pid: tuple | atom | pid,
                 entity: any
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @Fixture.History.Table
  #-----------------------------------------------------------------------------
  deftable Fixture.History.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: {tuple, integer},
                 entity: any
               }
  end # end deftable

end
