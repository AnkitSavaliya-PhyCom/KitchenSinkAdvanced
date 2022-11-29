#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.EmailService.V3.SendGrid.TransactionalEmail do
  alias Noizu.KitchenSink.V3.Types, as: T
  alias Noizu.EmailService.V3.Email.Binding
  
  
  require Logger

  @vsn 1.0

  @type t :: %__MODULE__{
               template: T.entity_reference,
               recipient: T.entity_reference,
               recipient_email: :default | String.t,
               sender: nil | T.entity_reference | any,
               reply_to: nil | T.entity_reference | any,
               bcc: list | nil,
               body: String.t,
               html_body: String.t,
               subject: String.t,

               bindings: Map.t,
               attachments: Map.t,
               vsn: float
             }

  defstruct [
    template: nil,
    recipient: nil,
    recipient_email: :default,
    sender: nil,
    reply_to: nil,
    bcc: nil,
    body: nil,
    html_body: nil,
    subject: nil,
    bindings: %{},
    attachments: %{},
    vsn: @vsn
  ]

  def email_queue_provider() do
    Application.get_env(:noizu_kitchen_sink_advanced, :email_queue_provider, Noizu.EmailService.V3.EmailQueue.Behaviour.DefaultProvider)
  end
  
  #--------------------------
  # send!/1
  #--------------------------
  @doc """
  @TODO cleanup implementation get rid of nested case statements.
  """
  def send!(%__MODULE__{} = this, context, options \\ %{}) do
    with {:ok, template} <- Noizu.ERP.entity_ok!(this.template),
         {:ok, template} <- Noizu.V3.Proto.EmailServiceTemplate.refresh!(template, context),
         {:ok, binding} <- Noizu.V3.Proto.EmailServiceTemplate.bind_template(template, this, context, options),
         {:ok, response} <- email_queue_provider().queue!(binding, context, options) do
      {:ok, response}
    else
      {_, binding = %Binding{state: {:error, details}}} ->
        #Todo prepare more information concerning bind failure.
        with {:ok, failure} <- email_queue_provider().queue_failure!(binding, details, context) do
          {:error, {:binding, details, failure}}
        end
      {:error, details} -> {:error, details}
    end
  end # end send!/1


  #--------------------------
  # send_email!/2
  #--------------------------
  def send_email!(queued_email, context, options \\ %{}) do
    with :attempt_delivery <- (simulate?() || options[:simulate_email] == true) && :simulate || :attempt_delivery,
         recipient <- Noizu.V3.Proto.EmailServiceQueue.recipient_email(queued_email, context, options),
         :unrestricted <- restricted?(recipient) && {:restricted, recipient} || :unrestricted do
      with {:sendgrid, sendgrid_template_id} <- Noizu.V3.Proto.EmailServiceQueue.template(queued_email, context, options) do
        binding = Noizu.V3.Proto.EmailServiceQueue.binding(queued_email, context, options)
        email = build_email(sendgrid_template_id, binding)
        with :ok <- SendGrid.Mail.send(email) do
          {:delivered, email}
        else
          {:error, error} ->
            {:error, {:delivery, error, email}}
          error ->
            {:error, {:delivery, error, email}}
        end
      else
        unsupported_template -> {:error, {:unsupported_template, unsupported_template}}
      end
    else
    {:restricted, recipient} ->
      {:restricted, {:recipient, recipient}}
    :simulate ->
        case Noizu.V3.Proto.EmailServiceQueue.template(queued_email, context, options) do
          {:sendgrid, sendgrid_template_id} ->
            binding = Noizu.V3.Proto.EmailServiceQueue.binding(queued_email, context, options)
            email = build_email(sendgrid_template_id, binding)
            {:simulated, {:email, email}}
          unsupported_template ->
            {:simulated, {:error, {:unsupported_template, unsupported_template}}}
        end
    end
  end # end send_email/3

  #--------------------------
  # build_email/2
  #--------------------------
  defp build_email(sendgrid_template_id, binding) do
    # Setup email
    SendGrid.Email.build()
    |> SendGrid.Email.put_template(sendgrid_template_id)
    |> put_sender(binding)
    |> put_recipient(binding)
    |> put_reply_to(binding)
    |> put_bcc(binding)
    |> put_text(binding)
    |> put_html(binding)
    |> put_subject(binding)
    |> put_substitutions(binding)
    |> put_attachments(binding)
  end # end build_email/2

  defp put_bcc(email, binding) do
      case binding.bcc do
        [] -> email
        v when is_list(v) ->
           Enum.reduce(v, email, fn(bcc, email) ->
             cond do
               bcc.name && bcc.email -> SendGrid.Email.add_bcc(email, bcc.email, bcc.name)
               bcc.email -> SendGrid.Email.add_bcc(email, bcc.email)
               :else -> email
             end
           end)
        _ -> email
      end
  end

  defp put_sender(email, binding) do
    cond do
      binding.sender_name -> SendGrid.Email.put_from(email, binding.sender_email, binding.sender_name)
      :else -> SendGrid.Email.put_from(email, binding.sender_email)
    end
  end

  defp put_recipient(email, binding) do
    cond do
      binding.recipient_name -> SendGrid.Email.add_to(email, binding.recipient_email, binding.recipient_name)
      :else -> SendGrid.Email.add_to(email, binding.recipient_email)
    end
  end

  defp put_reply_to(email, binding) do
    cond do
      binding.reply_to_email && binding.reply_to_name -> SendGrid.Email.put_reply_to(email, binding.reply_to_email, binding.reply_to_name)
      binding.reply_to_email -> SendGrid.Email.put_reply_to(email, binding.recipient_email)
      :else -> email
    end
  end




  #--------------------------
  # put_attachments
  #--------------------------
  def put_attachments(email, binding) do
    cond do
      is_map(binding.attachments) -> Enum.reduce(binding.attachments, email, fn({name, v}, email) ->
        cond do
          is_function(v, 0) ->
            case v.() do
              {:ok, attachment} -> SendGrid.Email.add_attachment(email, attachment)
              _ -> email
            end

          is_function(v, 2) ->
            case v.(name, binding) do
              {:ok, attachment} -> SendGrid.Email.add_attachment(email, attachment)
              _ -> email
            end
          is_map(v) -> SendGrid.Email.add_attachment(email, v)
          true-> email
        end
      end)
      true -> email
    end
  end

  #--------------------------
  # put_html/2
  #--------------------------
  defp put_html(email, binding) do
    binding.html_body && SendGrid.Email.put_html(email, binding.html_body) || email
  end # end put_html/2

  #--------------------------
  # put_body/2
  #--------------------------
  defp put_text(email, binding) do
    binding.body && SendGrid.Email.put_text(email, binding.body) || email
  end # end put_html/2

  #--------------------------
  # put_subject/2
  #--------------------------
  defp put_subject(email, binding) do
    binding.subject && SendGrid.Email.put_subject(email, binding.subject) || email
  end # end put_subject

  #--------------------------
  # put_substitutions/2
  #--------------------------
  def put_substitutions({substitution_key, substitution_value}, email) do
    if is_map(substitution_value) do
      Enum.reduce(substitution_value, email, fn({k,v}, acc) -> put_substitutions({"#{substitution_key}.#{k}", v}, acc) end)
    else
      SendGrid.Email.add_substitution(email, "-{#{substitution_key}}-", substitution_value)
    end
  end

  def put_substitutions(email, binding) do
    Noizu.V3.Proto.EmailServiceBinder.apply!(binding.effective_binding, email, Noizu.ElixirCore.CallingContext.system(), [])
  end # end put_substitutions/2

  #--------------------------
  # restricted?/1
  #--------------------------
  defp restricted?(email) do
    r = Application.get_env(:sendgrid, :restricted)
    cond do
      r != nil && r != false ->
        regex = Application.get_env(:sendgrid, :restricted_regex) || ~r/@(#{r})$/
        !(Regex.match?(regex, email))
      true -> false
    end
  end # end restricted?/1

  #--------------------------
  # put_html/2
  #--------------------------
  defp simulate?() do
    Application.get_env(:sendgrid, :simulate)
  end

end # end defmodule
