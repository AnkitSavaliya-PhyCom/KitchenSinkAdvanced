#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2019 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

use Amnesia
defdatabase Noizu.V3.CMS.Database do

  def database(), do: Noizu.V3.CMS.Database

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
  # @Record.Table
  #-----------------------------------------------------------------------------
  deftable Article.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 entity: any
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @Article.Index.Table
  #-----------------------------------------------------------------------------
  deftable Article.Index.Table,
           [:article, :status, :manager, :article_type, :editor, :created_on, :modified_on, :active_version, :active_revision],
           type: :set,
           index: [:status, :manager, :article_type, :editor, :created_on, :modified_on] do
    @type t :: %__MODULE__{
                 article: Noizu.KitchenSink.Types.entity_reference,
                 status: :approved | :pending | :disabled | atom,
                 manager: atom,
                 article_type: :post | :file | :image | :default | atom | any,
                 editor: Noizu.KitchenSink.Types.entity_reference,
                 created_on: integer,
                 modified_on: integer,
                 active_version: any,
                 active_revision: any,
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @Article.Tag.Table
  #-----------------------------------------------------------------------------
  deftable Article.Tag.Table, [:article, :tag], type: :bag, index: [:tag] do
    @type t :: %__MODULE__{
                 article: Noizu.KitchenSink.Types.entity_reference,
                 tag: atom,
               }
  end # end deftable

  #=============================================================================
  #=============================================================================
  # Versioning
  #=============================================================================
  #=============================================================================

  #-----------------------------------------------------------------------------
  # @Article.VersionSequencer.Table
  #-----------------------------------------------------------------------------
  deftable Article.VersionSequencer.Table, [:identifier, :sequence], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: any, # version ref
                 sequence: any,
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @Version.Table
  #-----------------------------------------------------------------------------
  deftable Article.Version.Table, [:identifier, :editor, :status,  :created_on, :modified_on, :entity], type: :set, index: [:editor, :status, :created_on, :modified_on] do
    @type t :: %__MODULE__{
                 identifier: any, # {article ref, path tuple}
                 editor: any,
                 status: any,
                 created_on: integer,
                 modified_on: integer,
                 entity: any, # VersionEntity
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @RevisionTable
  #-----------------------------------------------------------------------------
  deftable Article.Version.Revision.Table, [:identifier, :editor, :status, :created_on, :modified_on, :entity], type: :set, index: [:editor, :status, :created_on, :modified_on] do
    @type t :: %__MODULE__{
                 identifier: any, # { {article, version}, revision}
                 editor: any,
                 status: any,
                 created_on: any,
                 modified_on: any,
                 entity: any,
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @Active.Version.Table
  #-----------------------------------------------------------------------------
  deftable Article.Active.Version.Table, [:article, :version], type: :set, index: [] do
    @type t :: %__MODULE__{
                 article: any,
                 version: any,
               }
  end # end deftable


  #-----------------------------------------------------------------------------
  # @Active.Version.Table
  #-----------------------------------------------------------------------------
  deftable Article.Active.Version.Revision.Table, [:version, :revision], type: :set, index: [] do
    @type t :: %__MODULE__{
                 version: any,
                 revision: any,
               }
  end # end deftable


end
