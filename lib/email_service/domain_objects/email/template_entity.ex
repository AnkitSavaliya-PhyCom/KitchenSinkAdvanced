#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.EmailService.V3.Email.Template do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "email-template"
  @persistence_layer {Noizu.EmailService.V3.Database, cascade_block?: true, table: Noizu.EmailService.V3.Database.Email.Template.Table}
  defmodule Entity do
    @universal_identifier false
    @auto_generate false
    Noizu.DomainObject.noizu_entity() do
      identifier :compound, template: {{:atom, [constraint: :any]}, {:atom, [constraint: :any]}}
      public_field :synched_on
      public_field :cached

      public_field :name
      public_field :description
      public_field :external_template_identifier
      public_field :binding_defaults, []
      public_field :status, :active
      public_field :kind, __MODULE__
    end
    
    #--------------------------
    # refresh!
    #--------------------------
    def refresh!(%__MODULE__{} = this, context) do
      cond do
        simulate?() ->
          {:ok, this}
        (this.synched_on == nil || DateTime.compare(DateTime.utc_now, Timex.shift(this.synched_on, minutes: 30)) == :gt ) ->
          this = this.external_template_identifier
                 |> internal_refresh!(this)
                 |> Noizu.EmailService.V3.Email.Template.Repo.update!(context)
          {:ok, this}
        :else ->
          {:ok, this}
      end
    end # end refresh/1

    defp internal_refresh__cache(%SendGrid.LegacyTemplate{} = template) do
      # Grab Active Version
      version = Enum.find(template.versions, &(&1.active))

      # Grab Substitutions
      Noizu.EmailService.V3.Email.Binding.Substitution.Legacy.extract(version)
    end

    defp internal_refresh__cache(%SendGrid.DynamicTemplate{} = template) do
      # Grab Active Version
      version = Enum.find(template.versions, &(&1.active))

      # Grab Substitutions
      Noizu.EmailService.V3.Email.Binding.Substitution.Dynamic.extract(version)
    end

    #--------------------------
    # internal_refresh/2
    #--------------------------
    defp internal_refresh!({:sendgrid, identifier}, this) do
      # Load Template from SendGrid
      template = SendGrid.Templates.get(identifier)
      cached = internal_refresh__cache(template)

      # Return updated record
      %__MODULE__{this| cached: cached, synched_on: DateTime.utc_now()}
    end # end refresh/2

    #--------------------------
    # effective_binding
    #--------------------------
    def effective_binding(template, binding_input, context, options) do
      case template.cached do
        v =  %Noizu.EmailService.V3.Email.Binding.Substitution.Dynamic{} ->
          Noizu.EmailService.V3.Email.Binding.Substitution.Dynamic.effective_bindings(v, binding_input, context, options)

        v =  %Noizu.EmailService.V3.Email.Binding.Substitution.Legacy{binding: _substitutions} ->
          Noizu.EmailService.V3.Email.Binding.Substitution.Legacy.effective_bindings(v, binding_input, context, options)

        _ -> {:error, :not_supported}
      end
    end

    #--------------------------
    # refresh/1
    #--------------------------
    defp simulate?() do
      Application.get_env(:sendgrid, :simulate)
    end
  end


  defmodule Repo do
    Noizu.DomainObject.noizu_repo() do
    end
  end
end

defimpl Noizu.V3.Proto.EmailServiceTemplate, for: Noizu.EmailService.V3.Email.Template.Entity do
  defdelegate refresh!(template, context), to: Noizu.EmailService.V3.Email.Template.Entity
  def bind_template(template, txn_email, context, options \\ nil) do
    Noizu.EmailService.V3.Email.Binding.bind_from_template(txn_email, template, context, options)
  end
end
