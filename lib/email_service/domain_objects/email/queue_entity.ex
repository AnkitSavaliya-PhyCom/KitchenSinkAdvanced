#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.EmailService.V3.Email.Queue do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "queued-email"
  @persistence_layer {Noizu.EmailService.V3.Database, cascade_block?: true, table: Noizu.EmailService.V3.Database.Email.Queue.Table}
  defmodule Entity do
    @universal_identifier false
    Noizu.DomainObject.noizu_entity() do
      identifier :integer
      public_field :recipient
      public_field :sender
      public_field :state
      public_field :created_on, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
      public_field :retry_on, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
      public_field :template
      public_field :version
      public_field :binding
      public_field :email
      public_field :kind, __MODULE__
    end
  end

  defmodule Repo do

    require Logger
    alias Noizu.EmailService.V3.Email.Queue
    alias Noizu.ElixirCore.CallingContext
    alias Noizu.EmailService.V3.Email.Binding

    Noizu.DomainObject.noizu_repo() do
    end


    #--------------------------
    # queue_failed!
    #--------------------------
    def queue_failed!(binding, details, context) do
      queue_entry = %Queue.Entity{
                      recipient: binding.recipient,
                      sender: binding.sender,
                      state: {:error, details || :unknown},
                      created_on: DateTime.utc_now(),
                      retry_on: nil,
                      template: Noizu.ERP.ref(binding.template),
                      version: binding.template_version,
                      binding: binding,
                      email: nil,
                    } |> create!(CallingContext.system(context))

      ref = Noizu.ERP.ref(queue_entry)
      %Noizu.EmailService.V3.Email.Queue.Event.Entity{
        queue_item: ref,
        event: :failure,
        event_time: queue_entry.created_on,
        details: {:error, details || :unknown},
      } |> Noizu.EmailService.V3.Email.Queue.Event.Repo.create!(Noizu.ElixirCore.CallingContext.system(context))
      {:ok, queue_entry}
    end # end queue_failed/3

    #--------------------------
    # queue!
    #--------------------------
    def queue!(%Binding{} = binding, context) do
      time = DateTime.utc_now()
      queue = %Queue.Entity{
        recipient: binding.recipient,
        sender: binding.sender,
        state: :queued,
        created_on: time,
        retry_on: Timex.shift(time, minutes: 30),
        template: Noizu.ERP.ref(binding.template),
        version: binding.template_version,
        binding: binding,
        email: nil,
      } |> create!(CallingContext.system(context))
      queue && {:ok, queue} || {:error, :queue_update}
    end # end queue/2

    #--------------------------
    # update_state_and_history!
    #--------------------------
    def update_state_and_history!(%Queue.Entity{} = entity, :retrying, {event, details}, context) do
      retry_on = Timex.shift(DateTime.utc_now(), minutes: 30)
      queue_entry = %Queue.Entity{entity| retry_on: retry_on, state: :retrying}
                    |> update!(CallingContext.system(context))


      ref = Noizu.ERP.ref(queue_entry)
      %Noizu.EmailService.V3.Email.Queue.Event.Entity{
        queue_item: ref,
        event: event,
        event_time: DateTime.utc_now(),
        details: details,
      } |> Noizu.EmailService.V3.Email.Queue.Event.Repo.create!(Noizu.ElixirCore.CallingContext.system(context))

      queue_entry
    end # end update_state/2

    def update_state_and_history!(%Queue.Entity{} = entity, new_state, {event, details}, context) do
      queue_entry = %Queue.Entity{entity| retry_on: nil, state: new_state}
                    |> update!(CallingContext.system(context))

      ref = Noizu.ERP.ref(queue_entry)
      %Noizu.EmailService.V3.Email.Queue.Event.Entity{
        queue_item: ref,
        event: event,
        event_time: DateTime.utc_now(),
        details: details,
      } |> Noizu.EmailService.V3.Email.Queue.Event.Repo.create!(Noizu.ElixirCore.CallingContext.system(context))

      queue_entry
    end # end update_state/2

  end



end


defimpl Noizu.V3.Proto.EmailServiceQueue, for: [Noizu.EmailService.V3.Email.Queue.Entity] do
  def template(queue, _context, _options) do
    queue.binding.template_version.template
  end
  def version(queue, _context, _options) do
    queue.binding.template_version.version
  end
  
  def binding(queue, _context, _options) do
    queue.binding
  end
  
  def set_email(queue, email, _context, _options) do
    put_in(queue, [Access.key(:email)], email)
  end
  
  def recipient_email(queue, _context, _options) do
    queue.binding.recipient_email
  end
  
  def attempt_send(queued_email, context, options) do
    case Noizu.EmailService.V3.SendGrid.TransactionalEmail.send_email!(queued_email, context, options) do
      {:delivered, email} ->
        queued_email = cond do
                         options[:persist_email] -> put_in(queued_email, [Access.key(:email)], email)
                         :else -> queued_email
                       end
        details = case queued_email.state do
                    :queued -> :first_attempt
                    :retrying -> :retry_attempt
                    v -> v
                  end
        Noizu.EmailService.V3.Email.Queue.Repo.update_state_and_history!(queued_email, :delivered, {:delivered, details}, context)
      {:error, {:delivery, error, email}} ->
        queued_email = cond do
                         options[:persist_email] -> put_in(queued_email, [Access.key(:email)], email)
                         :else -> queued_email
                       end
        Noizu.EmailService.V3.Email.Queue.Repo.update_state_and_history!(queued_email, :retrying, {:error, {:error, error}}, context)
      {:error, {:unsupported_template, unsupported_template}} ->
        Noizu.EmailService.V3.Email.Queue.Repo.update_state_and_history!(queued_email, :error, {:error, {:unsupported_template, unsupported_template}}, context)
      {:restricted, {:recipient, recipient}} ->
        Noizu.EmailService.V3.Email.Queue.Repo.update_state_and_history!(queued_email, :restricted, {:restricted, recipient}, context)
      {:simulated, {:email, email}} ->
        queued_email = cond do
                         options[:persist_email] -> put_in(queued_email, [Access.key(:email)], email)
                         :else -> queued_email
                       end
        Noizu.EmailService.V3.Email.Queue.Repo.update_state_and_history!(queued_email, :delivered, {:delivered, :simulated}, context)
      {:simulated, {:error, {:unsupported_template, _}}} ->
        Noizu.EmailService.V3.Email.Queue.Repo.update_state_and_history!(queued_email, :delivered, {:delivered, :simulated}, context)
      error ->
        Noizu.EmailService.V3.Email.Queue.Repo.update_state_and_history!(queued_email, :retrying, {:error, {:error, error}}, context)
    end
  end
  
end
