#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.KitchenSink.V3.Support.User do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "test-user"
  @persistence_layer {Noizu.KitchenSink.V3.Database, cascade_block?: true, table: Noizu.KitchenSink.V3.Database.Support.User.Table}
  defmodule Entity do
    @universal_identifier false
    Noizu.DomainObject.noizu_entity() do
      identifier :integer
      public_field :name
      public_field :email
    end
    #=============================================================================
    # has_permission - cast|info
    #=============================================================================
    def has_permission(_ref, _permission, context, _options), do: context.auth[:permissions][:admin] || context.auth[:permissions][:system] || false
    def has_permission!(ref, permission, context, options), do: has_permission(ref, permission, context, options)
  end



  defmodule Repo do
    Noizu.DomainObject.noizu_repo() do
    end
  end

end # end defmodule

defimpl Noizu.V3.Proto.EmailAddress, for: Noizu.KitchenSink.V3.Support.User.Entity do
  def email_details(reference) do
    %{ref: Noizu.KitchenSink.V3.Support.User.Entity.ref(reference), name: reference.name, email: reference.email}
  end
end # end defimpl
