#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2022 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.V3.Proto.EmailServiceBinder do
  def apply!(binding, txn_email, context, options)
end # end defprotocol

defimpl Noizu.V3.Proto.EmailServiceBinder, for:  Noizu.EmailService.V3.Email.Binding.Substitution.Legacy.Effective do
  def apply!(binding, txn_email, _context, _options) do
    (binding.bound || %{})
    |> Enum.reduce(txn_email,
         fn({substitution_key, substitution_value}, acc) ->
           Noizu.EmailService.V3.SendGrid.TransactionalEmail.put_substitutions({substitution_key, substitution_value}, acc)
         end)
  end
end

defimpl Noizu.V3.Proto.EmailServiceBinder, for: Noizu.EmailService.V3.Email.Binding.Substitution.Dynamic.Effective do
  def apply!(binding, txn_email, _context, _options) do
    (binding.bound || %{})
    |> Enum.reduce(txn_email,
         fn({dynamic_key, dynamic_value}, acc) ->
           SendGrid.Email.add_dynamic_template_data(acc, dynamic_key, dynamic_value)
         end)
  end
end
