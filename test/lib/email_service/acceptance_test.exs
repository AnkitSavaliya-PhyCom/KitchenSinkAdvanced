#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.EmailService.V3.AcceptanceTest do
  use ExUnit.Case, async: false
  require Logger

  @context Noizu.ElixirCore.CallingContext.admin()

  def assert_eventually(msg, lambda, timeout \\ 5_000) do
    timeout = cond do
                timeout < 100_000 -> :os.system_time(:millisecond) + timeout
                :else -> timeout
              end

      cond do
        :os.system_time(:millisecond) < timeout ->
          cond do
            v = lambda.() -> v
            :else ->
              Process.sleep(100)
              assert_eventually(msg, lambda, timeout)
          end
        :else ->
          cond do
            v = lambda.() -> v
            :else -> assert :timeout == msg
          end
      end
  end

  @tag :email
  @tag :wip
  test "Template Persistence" do
    %Noizu.EmailService.V3.Email.Template.Entity{
      identifier: {:noizu, :template}
    } |> Noizu.EmailService.V3.Email.Template.Repo.create!(@context)
    sut = Noizu.EmailService.V3.Email.Template.Entity.entity!({:noizu, :template})
    assert sut != nil
    assert sut.identifier == {:noizu, :template}
  end
  
  @tag :email
  @tag :legacy_email
  test "Send Transactional Email (Legacy)" do
    template = Noizu.EmailService.V3.Email.Template.Repo.get!({:noizu, :test_template}, @context)
               |> Noizu.V3.Proto.EmailServiceTemplate.refresh!(@context)
    template_ref = Noizu.EmailService.V3.Email.Template.Entity.ref(template)
    recipient = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Recipient Name", email: "keith.brings+recipient@noizu.com"}
                |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    sender = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Sender Name", email: "keith.brings+sender@noizu.com"}
             |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)

    email = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: template_ref,
      recipient: recipient,
      recipient_email: nil,
      sender: sender,
      body: "Email Body",
      html_body: "HTML Email Body",
      subject: "Email Subject",
      bindings: %{"foo" => %{"bar" => "foo-bizz"}},
    }
    sut = Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(email, @context, %{persist_email: true})
    assert sut.__struct__ == Noizu.EmailService.V3.Email.Queue.Entity
    assert sut.binding.effective_binding.outcome == :ok
    assert sut.binding.effective_binding.outcome == :ok
    assert sut.binding.effective_binding.bound == %{"default_field" => "default_value", "foo.bar" => "foo-bizz", "site" => "https://github.com/noizu/KitchenSink"}
    assert sut.binding.recipient_email == "keith.brings+recipient@noizu.com"
    assert sut.binding.body == "Email Body"
    assert sut.binding.html_body == "HTML Email Body"
    # Delay to allow send to complete.
    Process.sleep(1000)

    assert_eventually(:email_delivered, fn() ->
      queue_entry = Noizu.EmailService.V3.Database.Email.Queue.Table.read!(sut.identifier)
      Enum.member?([:delivered], queue_entry.state)
    end)

    # Verify email settings
    sut = Noizu.EmailService.V3.Database.Email.Queue.Table.read!(sut.identifier).entity
    assert sut.email != nil
    assert sut.email.to == [%{email: "keith.brings+recipient@noizu.com", name: "Recipient Name"}]
    assert sut.email.from == %{email: "keith.brings+sender@noizu.com", name: "Sender Name"}
    assert sut.email.reply_to == nil
    assert sut.email.bcc == nil

    queue_entry_ref = Noizu.ERP.ref(sut)
    history = Noizu.EmailService.V3.Database.Email.Queue.Event.Table.match!(queue_item: queue_entry_ref) |> Amnesia.Selection.values
    assert length(history) == 1
    [h] = history
    assert h.entity.event == :delivered
    assert h.entity.details == :first_attempt
  end


  @tag :email
  @tag :legacy_email
  test "Send Transactional Email (Legacy) email overrides and raw email persistence" do
    template = Noizu.EmailService.V3.Email.Template.Repo.get!({:noizu, :test_template}, @context)
               |> Noizu.V3.Proto.EmailServiceTemplate.refresh!(@context)
    template_ref = Noizu.EmailService.V3.Email.Template.Entity.ref(template)
    recipient = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Recipient Name", email: "keith.brings+recipient@noizu.com"}
                |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    sender = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Sender Name", email: "keith.brings+sender@noizu.com"}
             |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
             |> Noizu.ERP.ref()

    bcc = [
      %Noizu.KitchenSink.V3.Support.User.Entity{name: nil, email: "keith.brings+bcc1@noizu.com"},
      %Noizu.KitchenSink.V3.Support.User.Entity{name: "BCC Name", email: "keith.brings+bcc2@noizu.com"}
    ]

    reply_to = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Reply To Name", email: "keith.brings+reply@noizu.com"}

    email = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: template_ref,
      recipient: recipient,
      recipient_email: "keith.brings+override@noizu.com",
      sender: sender,
      reply_to: reply_to,
      bcc: bcc,
      body: "Email Body",
      html_body: "HTML Email Body",
      subject: "Email Subject",
      bindings: %{"foo" => %{"bar" => "foo-bizz"}},
    }
    sut = Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(email, @context, %{persist_email: true, simulate_email: true})

    assert_eventually(:email_delivered, fn() ->
      queue_entry = Noizu.EmailService.V3.Database.Email.Queue.Table.read!(sut.identifier)
      Enum.member?([:delivered], queue_entry.state)
    end)

    # Verify email override and reply to
    sut = Noizu.EmailService.V3.Database.Email.Queue.Table.read!(sut.identifier).entity
    assert sut.email != nil
    assert sut.email.to == [%{email: "keith.brings+override@noizu.com", name: "Recipient Name"}]
    assert sut.email.from == %{email: "keith.brings+sender@noizu.com", name: "Sender Name"}
    assert sut.email.reply_to == %{email: "keith.brings+reply@noizu.com", name: "Reply To Name"}
    assert sut.email.bcc == [%{email: "keith.brings+bcc1@noizu.com"}, %{email: "keith.brings+bcc2@noizu.com", name: "BCC Name"}]

    # Verify simulated send
    queue_entry_ref = Noizu.ERP.ref(sut)
    history = Noizu.EmailService.V3.Database.Email.Queue.Event.Table.match!(queue_item: queue_entry_ref) |> Amnesia.Selection.values
    assert length(history) == 1
    [h] = history
    assert h.entity.event == :delivered
    assert h.entity.details == :simulated
  end


  @tag :email
  @tag :legacy_email
  test "Send Transactional Email (Legacy) invalid bcc" do
    template = Noizu.EmailService.V3.Email.Template.Repo.get!({:noizu, :test_template}, @context)
               |> Noizu.V3.Proto.EmailServiceTemplate.refresh!(@context)
    template_ref = Noizu.EmailService.V3.Email.Template.Entity.ref(template)
    recipient = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Recipient Name", email: "keith.brings+recipient@noizu.com"}
                |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    sender = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Sender Name", email: "keith.brings+sender@noizu.com"}
             |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
             |> Noizu.ERP.ref()

    bcc = [
      %Noizu.KitchenSink.V3.Support.User.Entity{name: nil, email: "keith.brings+bcc1@noizu.com"},
      %Noizu.KitchenSink.V3.Support.User.Entity{name: "BCC Name", email: "keith.brings+bcc2@noizu.com"},
      nil
    ]

    reply_to = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Reply To Name", email: "keith.brings+reply@noizu.com"}

    email = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: template_ref,
      recipient: recipient,
      recipient_email: "keith.brings+override@noizu.com",
      sender: sender,
      reply_to: reply_to,
      bcc: bcc,
      body: "Email Body",
      html_body: "HTML Email Body",
      subject: "Email Subject",
      bindings: %{"foo" => %{"bar" => "foo-bizz"}},
    }
    sut = Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(email, @context, %{persist_email: true, simulate_email: true})
    assert sut.state == {:error, :invalid_bcc}
  end


  @tag :email
  @tag :legacy_email
  test "Send Transactional Email (Legacy) invalid recipient" do
    template = Noizu.EmailService.V3.Email.Template.Repo.get!({:noizu, :test_template}, @context)
               |> Noizu.V3.Proto.EmailServiceTemplate.refresh!(@context)
    template_ref = Noizu.EmailService.V3.Email.Template.Entity.ref(template)
    recipient = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Recipient Name", email: nil}
                |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    sender = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Sender Name", email: "keith.brings+sender@noizu.com"}
             |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
             |> Noizu.ERP.ref()

    reply_to = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Reply To Name", email: "keith.brings+reply@noizu.com"}

    email = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: template_ref,
      recipient: recipient,
      recipient_email: nil,
      sender: sender,
      reply_to: reply_to,
      body: "Email Body",
      html_body: "HTML Email Body",
      subject: "Email Subject",
      bindings: %{"foo" => %{"bar" => "foo-bizz"}},
    }
    sut = Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(email, @context, %{persist_email: true, simulate_email: true})
    assert sut.state == {:error, :recipient_required}
  end


  @tag :email
  @tag :legacy_email
  test "Send Transactional Email (Legacy) invalid sender" do
    template = Noizu.EmailService.V3.Email.Template.Repo.get!({:noizu, :test_template}, @context)
               |> Noizu.V3.Proto.EmailServiceTemplate.refresh!(@context)
    template_ref = Noizu.EmailService.V3.Email.Template.Entity.ref(template)
    recipient = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Recipient Name", email: "keith.brings+recipient@noizu.com"}
                |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    sender = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Sender Name", email: nil}
             |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
             |> Noizu.ERP.ref()

    reply_to = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Reply To Name", email: "keith.brings+reply@noizu.com"}

    email = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: template_ref,
      recipient: recipient,
      recipient_email: nil,
      sender: sender,
      reply_to: reply_to,
      body: "Email Body",
      html_body: "HTML Email Body",
      subject: "Email Subject",
      bindings: %{"foo" => %{"bar" => "foo-bizz"}},
    }
    sut = Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(email, @context, %{persist_email: true, simulate_email: true})
    assert sut.state == {:error, :sender_required}
  end


  @tag :email
  @tag :legacy_email
  test "Send Transactional Email (Legacy) invalid reply_to" do
    template = Noizu.EmailService.V3.Email.Template.Repo.get!({:noizu, :test_template}, @context)
               |> Noizu.V3.Proto.EmailServiceTemplate.refresh!(@context)
    template_ref = Noizu.EmailService.V3.Email.Template.Entity.ref(template)
    recipient = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Recipient Name", email: "keith.brings+recipient@noizu.com"}
                |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    sender = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Sender Name", email: "keith.brings+sender@noizu.com"}
             |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
             |> Noizu.ERP.ref()

    reply_to = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Reply To Name", email: nil}

    email = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: template_ref,
      recipient: recipient,
      recipient_email: nil,
      sender: sender,
      reply_to: reply_to,
      body: "Email Body",
      html_body: "HTML Email Body",
      subject: "Email Subject",
      bindings: %{"foo" => %{"bar" => "foo-bizz"}},
    }
    sut = Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(email, @context, %{persist_email: true, simulate_email: true})
    assert sut.state == {:error, :invalid_reply_to}
  end

  @tag :email
  @tag :legacy_email
  test "Send Transactional Email Failure (Legacy)" do
    template = Noizu.EmailService.V3.Email.Template.Repo.get!({:noizu, :test_template}, @context)
               |> Noizu.V3.Proto.EmailServiceTemplate.refresh!(@context)
    template_ref = Noizu.EmailService.V3.Email.Template.Entity.ref(template)
    recipient = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Recipient Name", email: "keith.brings+recipient@noizu.com"}
                |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    sender = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Sender Name", email: "keith.brings+sender@noizu.com"}
             |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)

    email = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: template_ref,
      recipient: recipient,
      recipient_email: nil,
      sender: sender,
      body: "Email Body",
      html_body: "HTML Email Body",
      subject: "Email Subject",
      bindings: %{"foo" => %{}},
    }
    sut = Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(email, @context)
    assert sut.__struct__ == Noizu.EmailService.V3.Email.Queue.Entity
    assert sut.binding.effective_binding.outcome == {:error, :unbound_fields}
    assert sut.state == {:error, :unbound_fields}

    queue_entry_ref = Noizu.ERP.ref(sut)
    history = Noizu.EmailService.V3.Database.Email.Queue.Event.Table.match!(queue_item: queue_entry_ref) |> Amnesia.Selection.values
    assert length(history) == 1
    [h] = history
    assert h.entity.event == :failure
    assert h.entity.details == {:error, :unbound_fields}
  end


  @tag :email
  @tag :dynamic_email
  test "Send Transactional Email (Dynamic)" do
    template = Noizu.EmailService.V3.Email.Template.Repo.get!({:noizu, :test_dynamic_template}, @context)
               |> Noizu.V3.Proto.EmailServiceTemplate.refresh!(@context)
    template_ref = Noizu.EmailService.V3.Email.Template.Entity.ref(template)

    recipient = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Recipient Name", email: "keith.brings+recipient@noizu.com"}
                |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)

    sender = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Sender Name", email: "keith.brings+sender@noizu.com"}
             |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)

    email = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: template_ref,
      recipient: recipient,
      recipient_email: nil,
      sender: sender,
      body: nil,
      html_body: nil,
      subject: nil, # Note setting a subject for dynamic template will result in an error state, and email will be sent with out subject line. @todo detect for this.
      bindings: %{alert: %{language: %{"French" => true, "German" => false}, devices: "37001", temperature: %{low: %{unit: :celsius, value: 3.23}, current: %{unit: :celsius, value: 3.23}}, name: :wip}},
    }
    sut = Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(email, @context)
    assert sut.state == :queued
    assert sut.__struct__ == Noizu.EmailService.V3.Email.Queue.Entity
    assert sut.binding.state == :ok
    assert sut.binding.effective_binding.outcome == :ok
    assert sut.binding.effective_binding.bound == %{"alert" => %{"language" => %{"French" => true, "German" => false}, "name" => :wip, "temperature" => %{"low" => %{"unit" => :celsius, "value" => 3.23}}}}
    assert sut.binding.recipient_email == "keith.brings+recipient@noizu.com"
    assert sut.binding.body == nil
    assert sut.binding.html_body == nil
    # Delay to allow send to complete.

    assert_eventually(:email_delivered, fn() ->
      queue_entry = Noizu.EmailService.V3.Database.Email.Queue.Table.read!(sut.identifier)
      Enum.member?([:delivered], queue_entry.state)
    end)

    queue_entry_ref = Noizu.ERP.ref(sut)
    history = Noizu.EmailService.V3.Database.Email.Queue.Event.Table.match!(queue_item: queue_entry_ref) |> Amnesia.Selection.values
    assert length(history) == 1
    [h] = history
    assert h.entity.event == :delivered
    assert h.entity.details == :first_attempt
  end

  @tag :email
  @tag :dynamic_email
  test "Send Transactional Email Failure (Dynamic)" do
    template = Noizu.EmailService.V3.Email.Template.Repo.get!({:noizu, :test_dynamic_template}, @context)
               |> Noizu.V3.Proto.EmailServiceTemplate.refresh!(@context)
    template_ref = Noizu.EmailService.V3.Email.Template.Entity.ref(template)

    recipient = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Recipient Name", email: "keith.brings+recipient@noizu.com"}
                |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)

    sender = %Noizu.KitchenSink.V3.Support.User.Entity{name: "Sender Name", email: "keith.brings+sender@noizu.com"}
             |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)

    email = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: template_ref,
      recipient: recipient,
      recipient_email: nil,
      sender: sender,
      body: nil,
      html_body: nil,
      subject: nil,
      bindings: %{alert: %{language: %{"German" => true}}},
    }
    sut = Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(email, @context)
    assert sut.__struct__ == Noizu.EmailService.V3.Email.Queue.Entity
    assert sut.state == {:error, :unbound_fields}
    assert sut.binding.effective_binding.outcome == {:error, :unbound_fields}
    assert sut.binding.state == {:error, :unbound_fields}

    queue_entry_ref = Noizu.ERP.ref(sut)
    history = Noizu.EmailService.V3.Database.Email.Queue.Event.Table.match!(queue_item: queue_entry_ref) |> Amnesia.Selection.values
    assert length(history) == 1
    [h] = history
    assert h.entity.event == :failure
    assert h.entity.details == {:error, :unbound_fields}
  end
end
