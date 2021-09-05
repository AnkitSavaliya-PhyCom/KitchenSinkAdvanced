#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

use Amnesia

defdatabase Noizu.KitchenSink.V3.Database do

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
  # @Support.UserTable
  #-----------------------------------------------------------------------------
  deftable Support.User.Table, [:identifier, :entity], type: :set, index: [] do
    @moduledoc """
    Test User Table
    """
    @type t :: %__MODULE__{identifier: integer, entity: any}
  end # end deftable
end
