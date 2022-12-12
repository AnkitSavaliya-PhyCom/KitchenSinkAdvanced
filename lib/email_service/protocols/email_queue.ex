#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2020 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.V3.Proto.EmailServiceQueue do
  def template(queue, context, options)
  def version(queue, context, options)
  def binding(queue, context, options)
  def set_email(queue, email, context, options)
  def attempt_send(queue, context, options)
  def recipient_email(queue, context, options)
end # end defprotocol
