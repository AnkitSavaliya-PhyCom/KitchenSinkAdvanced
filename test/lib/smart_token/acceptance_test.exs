#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.SmartToken.V3.AcceptanceTest do
  use ExUnit.Case, async: false
  require Logger

  @context Noizu.ElixirCore.CallingContext.admin()
  @conn_stub %{remote_ip: {127, 0, 0, 1}}

  @tag :smart_token
  test "Account Verification Create & Redeem" do
    user = %Noizu.KitchenSink.V3.Support.User.Entity{name: "SmartToken Account Verification Test"}
           |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    user_ref = Noizu.KitchenSink.V3.Support.User.Entity.ref(user)
    bindings = %{recipient: user_ref}
    smart_token = Noizu.SmartToken.V3.Token.Repo.account_verification_token(%{})
                  |> Noizu.SmartToken.V3.Token.Repo.bind!(bindings, @context, %{})
    encoded_link = Noizu.SmartToken.V3.Token.Entity.encoded_key(smart_token)

    assert smart_token.access_history.count == 0
    assert smart_token.context == user_ref
    assert smart_token.extended_info[:single_use] == true
    assert smart_token.resource == user_ref
    assert smart_token.scope == {:account_info, :verification}
    assert smart_token.state == :enabled
    assert smart_token.type == :account_verification
    assert smart_token.permissions == :unrestricted


    {attempt, token} = Noizu.SmartToken.V3.Token.Repo.authorize!(encoded_link, @conn_stub, @context)
    assert attempt == :ok
    assert token.resource == user_ref
  end

  @tag :smart_token
  test "Account Verification - Max Attempts Exceeded - Single Use" do
    user = %Noizu.KitchenSink.V3.Support.User.Entity{name: "SmartToken Account Verification Test"}
           |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    user_ref = Noizu.KitchenSink.V3.Support.User.Entity.ref(user)
    bindings = %{recipient: user_ref}
    smart_token = Noizu.SmartToken.V3.Token.Repo.account_verification_token(%{})
                  |> Noizu.SmartToken.V3.Token.Repo.bind!(bindings, @context, %{})
    encoded_link = Noizu.SmartToken.V3.Token.Entity.encoded_key(smart_token)

    Noizu.SmartToken.V3.Token.Repo.authorize!(encoded_link, @conn_stub, @context)
    attempt = Noizu.SmartToken.V3.Token.Repo.authorize!(encoded_link, @conn_stub, @context)
    assert attempt == {:error, :invalid}
  end

  @tag :smart_token
  test "Account Verification - Max Attempts Exceeded - Multi Use" do
    user = %Noizu.KitchenSink.V3.Support.User.Entity{name: "SmartToken Account Verification Test"}
           |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    user_ref = Noizu.KitchenSink.V3.Support.User.Entity.ref(user)
    bindings = %{recipient: user_ref}
    options = %{extended_info: %{multi_use: true, limit: 3}}
    smart_token = Noizu.SmartToken.V3.Token.Repo.account_verification_token(options)
                  |> Noizu.SmartToken.V3.Token.Repo.bind!(bindings, @context, %{})
    encoded_link = Noizu.SmartToken.V3.Token.Entity.encoded_key(smart_token)

    {attempt, _token} = Noizu.SmartToken.V3.Token.Repo.authorize!(encoded_link, @conn_stub, @context)
    assert attempt == :ok
    {attempt, _token} = Noizu.SmartToken.V3.Token.Repo.authorize!(encoded_link, @conn_stub, @context)
    assert attempt == :ok
    {attempt, _token} = Noizu.SmartToken.V3.Token.Repo.authorize!(encoded_link, @conn_stub, @context)
    assert attempt == :ok
    attempt = Noizu.SmartToken.V3.Token.Repo.authorize!(encoded_link, @conn_stub, @context)
    assert attempt == {:error, :invalid}
  end

  @tag :smart_token
  test "Account Verification - Expired" do
    user = %Noizu.KitchenSink.V3.Support.User.Entity{name: "SmartToken Account Verification Test"}
           |> Noizu.KitchenSink.V3.Support.User.Repo.create!(@context)
    user_ref = Noizu.KitchenSink.V3.Support.User.Entity.ref(user)
    bindings = %{recipient: user_ref}
    options = %{extended_info: %{multi_use: true, limit: 3}}
    smart_token = Noizu.SmartToken.V3.Token.Repo.account_verification_token(options)
                  |> Noizu.SmartToken.V3.Token.Repo.bind!(bindings, @context, %{})
    encoded_link = Noizu.SmartToken.V3.Token.Entity.encoded_key(smart_token)

    {attempt, _token} = Noizu.SmartToken.V3.Token.Repo.authorize!(encoded_link, @conn_stub, @context)
    assert attempt == :ok

    past_expiration = DateTime.utc_now() |> Timex.shift(days: 5)
    options = %{current_time: past_expiration}
    attempt = Noizu.SmartToken.V3.Token.Repo.authorize!(encoded_link, @conn_stub, @context, options)
    assert attempt == {:error, :invalid}
  end

end
