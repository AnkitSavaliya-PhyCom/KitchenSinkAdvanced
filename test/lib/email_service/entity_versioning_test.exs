#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.EmailService.V3.EntityVersioningTest do
  use ExUnit.Case, async: false
  require Logger

  @context Noizu.ElixirCore.CallingContext.admin()

  @tag :email
  @tag :email_upgrade
  test "Upgrade Binding vsn" do
    vsn_1_0 = %{
      __struct__: Noizu.EmailService.V3.Email.Binding,
      recipient: nil,
      recipient_name: :default,
      recipient_email: :default,
      sender: nil,
      sender_name: :default,
      sender_email: :default,
      body: nil,
      html_body: nil,
      subject: nil,
      template: {:ref, Noizu.EmailService.V3.Email.Template.Repo, :test_template},
      template_version: nil,
      state: :valid,
      substitutions: %{"foo.biz" => "xyz"},
      unbound: %{"foo.bar" => {:error, :not_bound}},
      attachments: nil,
      vsn: 1.0
    }
    sut = Noizu.EmailService.V3.Email.Binding.update_version(vsn_1_0, @context, %{})
    assert sut.effective_binding.bind == ["foo.biz", "foo.bar"]
    assert sut.effective_binding.unbound.optional == []
    assert sut.effective_binding.unbound.required == [{"foo.bar", {:error, :not_bound}}]
    assert sut.effective_binding.bound == %{"foo.biz" => "xyz"}
    assert sut.template == {:ref, Noizu.EmailService.V3.Email.Template.Repo, :test_template}
    assert sut.state == {:error, :unbound_fields}
    assert sut.vsn == 1.0
  end

end
