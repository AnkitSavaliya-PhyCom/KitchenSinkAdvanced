#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

use Amnesia
defdatabase Noizu.SmartToken.V3.Database do

  def database(), do: Noizu.SmartToken.V3.Database


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
  # @SmartTokens
  #-----------------------------------------------------------------------------
  deftable Token.Table, [:identifier, :active, :token, :entity], type: :set, index: [:active, :token]  do
    @moduledoc """
    Smart Tokens
    """
    @type t :: %Token.Table{
                 identifier: integer,
                 active: true,
                 token: {String.t, String.t},
                 entity: any,
               }
  end # end deftable SmartTokens
end
