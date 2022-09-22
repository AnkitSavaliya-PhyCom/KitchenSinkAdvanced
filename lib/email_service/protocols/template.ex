#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2020 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.V3.Proto.EmailServiceTemplate do
  def refresh!(template, context)
end # end defprotocol
