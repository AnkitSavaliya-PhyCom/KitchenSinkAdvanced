#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.V3.Proto.DynamicBind do
  @fallback_to_any true
  @doc "Format bound parameter into expected string representation for passing to sendgrid."
  def bind_value(reference, context, options)
end # end defprotocol

defimpl Noizu.V3.Proto.DynamicBind, for: Any do
  def bind_value(reference, context, options) do
    Noizu.RestrictedAccess.Protocol.restricted_view(reference, context, options)
  end # end format/1
end # end defimpl

defimpl Noizu.V3.Proto.DynamicBind, for: Noizu.SmartToken.V3.Token.Entity do
  def bind_value(reference, _context, _options) do
    case Noizu.SmartToken.V3.Token.Entity.encoded_key(reference) do
      {:error, _details} -> "invalid_token"
      v -> v
    end
  end # end format/1
end # end defimpl