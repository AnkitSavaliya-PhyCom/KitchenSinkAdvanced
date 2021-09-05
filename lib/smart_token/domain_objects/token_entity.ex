#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.SmartToken.V3.Token do
  @moduledoc """
    This class is used to represent a token that will be generated and stored to mnesia.
    It's data structure allows for late binding of fields like recipient, time_period, etc.
    On created late bindings are converted to final values.
  """

  use Noizu.DomainObject
  @vsn 1.0
  @sref "smart-token"
  @persistence_layer {Noizu.SmartToken.V3.Database, cascade_block?: true, table:  Noizu.SmartToken.V3.Database.Token.Table}
  defmodule Entity do
    @universal_identifier false
    Noizu.DomainObject.noizu_entity() do
      identifier :integer
      public_field :token, :generate
      public_field :type
      public_field :resource
      public_field :scope
      public_field :active, true
      public_field :state
      public_field :context
      public_field :owner
      public_field :validity_period
      public_field :permissions
      public_field :extended_info
      public_field :access_history
      public_field :template
      public_field :kind, __MODULE__
    end



    #---------------------------
    # encoded_key
    #---------------------------
    def encoded_key(%__MODULE__{} = this) do
      case this.token do
        {l, r} -> Base.url_encode64((UUID.string_to_binary!(l) <> UUID.string_to_binary!(r)))
        _ -> {:error, {:invalid_token, this.token}}
      end
    end

    #---------------------------
    #
    #---------------------------
    def bind(%__MODULE__{} = this, bindings, options) do
      %__MODULE__{this|
        token: bind_token(this.token, bindings),
        resource: bind_ref(this.resource, bindings),
        context: bind_ref(this.context, bindings),
        owner: bind_ref(this.owner, bindings),
        validity_period: bind_period(this, bindings, options),
        access_history: %{history: [], count: 0},
        template: this
      }
    end

    #---------------------------
    #
    #---------------------------
    def bind_ref(ref, bindings) do
      case ref do
        {:bind, path} when is_list(path) -> get_in(bindings, path) |> Noizu.ERP.ref()
        {:bind, field} -> get_in(bindings, [field]) |> Noizu.ERP.ref()
        _ -> ref
      end
    end

    #---------------------------
    #
    #---------------------------
    def bind_token(:generate, _bindings) do
      {UUID.uuid4(), UUID.uuid4()}
    end
    def bind_token(token, _bindings), do: token

    #---------------------------
    #
    #---------------------------
    def bind_period(%__MODULE__{} = this, _bindings, options) do
      current_time = options[:current_time] || DateTime.utc_now()
      case this.validity_period do
        :nil -> :nil
        {lv, rv} ->
          lv = case lv do
                 :unbound -> :unbound
                 {:relative, shift} -> Timex.shift(current_time, shift)
                 {:fixed, time} -> time
               end
          rv = case rv do
                 :unbound -> :unbound
                 {:relative, shift} -> Timex.shift(current_time, shift)
                 {:fixed, time} -> time
               end
          {lv, rv}
      end
    end

    #---------------------------
    # validate/4
    #---------------------------
    def validate(this, _conn, _context, options) do
      this = entity!(this)

      p_c = validate_period(this, options)
      a_c = validate_access_count(this)

      cond do
        p_c == :valid && a_c == :valid -> {:ok, this}
        true -> {:error, {{:period, p_c}, {:access_count, a_c}}}
      end
    end


    #---------------------------
    # validate_period/2
    #---------------------------
    def validate_period(this, options) do
      current_time = options[:current_time] || DateTime.utc_now()
      case this.validity_period do
        nil -> :valid
        :unbound -> :valid
        {l_bound, r_bound} ->
          cond do
            l_bound != :unbound && DateTime.compare(current_time, l_bound) == :lt -> {:error, :lt_range}
            r_bound != :unbound && DateTime.compare(current_time, r_bound) == :gt -> {:error, :gt_range}
            true -> :valid
          end
      end
    end

    #---------------------------
    # access_count/1
    #---------------------------
    def access_count(%__MODULE__{} = this) do
      this.access_history.count
    end

    #---------------------------
    # validate_access_count/1
    #---------------------------
    def validate_access_count(%__MODULE__{} = this) do
      case this.extended_info do
        %{single_use: true} ->
          # confirm first valid check
          if access_count(this) == 0 do
            :valid
          else
            {:error, :single_use_exceeded}
          end

        %{multi_use: true, limit: limit} ->
          if access_count(this) < limit do
            :valid
          else
            {:error, :multi_use_exceeded}
          end
        %{unlimited_use: true} -> :valid
      end
    end

    #---------------------------
    # record_valid_access!/2
    #---------------------------
    def record_valid_access!(%__MODULE{} = this, conn, options) do
      current_time = options[:current_time] || DateTime.utc_now()
      ip = conn && conn.remote_ip && conn.remote_ip |> Tuple.to_list |> Enum.join(".")
      entry = %{time: current_time, ip: ip,  type: :valid}
      record_access!(this, entry)
    end

    #---------------------------
    # record_access!/3
    #---------------------------
    def record_access!(%__MODULE__{} = this, entry) do
      this
      |> update_in([Access.key(:access_history), :count], &((&1 || 0) + 1))
      |> update_in([Access.key(:access_history), :history], &((&1 || []) ++ [entry]))
      |> Noizu.SmartToken.V3.Token.Repo.update!(Noizu.ElixirCore.CallingContext.system())
    end

    #---------------------------
    # record_invalid_access/2
    #---------------------------
    def record_invalid_access!(tokens, conn, options) when is_list(tokens) do
      current_time = options[:current_time] || DateTime.utc_now()
      ip = conn && conn.remote_ip && conn.remote_ip |> Tuple.to_list |> Enum.join(".")
      entry = %{time: current_time, ip: ip,  type: {:error, :check_mismatch}}
      # TODO deal with active flag if it needs to be changed. @PRI-2
      Enum.map(tokens, fn(token) ->
        record_access!(token, entry)
      end)
    end

    def record_invalid_access!(%__MODULE{} = this, conn, options) do
      current_time = options[:current_time] || DateTime.utc_now()
      ip = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
      entry = %{time: current_time, ip: ip,  type: {:error, :check_mismatch}}
      record_access!(this, entry)
    end

  end

  defmodule Repo do

    require Logger
    #alias Noizu.EmailService.V3.Email.Queue.Entity
    #alias Noizu.ElixirCore.CallingContext
    #alias Noizu.EmailService.V3.Email.Binding

    Noizu.DomainObject.noizu_repo() do
    end


    # Time Periods
    @period_three_days {:unbound, {:relative, [{:days, 3}]}}
    @period_fifteen_days {:unbound, {:relative, [{:days, 15}]}}

    @default_settings %{
      type: :generic,
      token: :generate,
      resource: {:bind, :recipient},
      state: :enabled,
      owner: :system,
      validity_period: :nil,
      permissions: :unrestricted,
      extended_info: :nil,
      scope: :nil,
      context: {:bind, :recipient}
    }


    #-------------------------------------
    # new/2
    #-------------------------------------
    def new(settings) do
      settings = Map.merge(@default_settings, settings)
      %Noizu.SmartToken.V3.Token.Entity{
        type: settings.type,
        token: settings.token,
        resource: settings.resource,
        scope: settings.scope,
        state: settings.state,
        context: settings.context,
        owner: settings.owner,
        validity_period: settings.validity_period,
        permissions: settings.permissions,
        extended_info: settings.extended_info,
        vsn: @vsn
      }
    end

    #-------------------------------------
    # account_verification_token/1
    #-------------------------------------
    def account_verification_token(options \\ %{}) do
      %{
        resource: {:bind, :recipient},
        context: {:bind, :recipient},
        scope: {:account_info, :verification},
        validity_period: @period_three_days,
        extended_info: %{single_use: true}
      }
      |> Map.merge(options)
      |> put_in([:type], :account_verification)
      |> new()
    end

    #-------------------------------------
    # edit_resource_token/3
    #-------------------------------------
    def edit_resource_token(resource, scope, options) do
      %{
        context: {:bind, :recipient},
        validity_period: @period_fifteen_days,
        extended_info: %{multi_use: true, limit: 25}
      }
      |> Map.merge(options)
      |> Map.merge(%{resource: resource, scope: scope, type: :edit_resource})
      |> new()
    end

    #-------------------------------------
    # authorize!/3
    #-------------------------------------
    def authorize!(token_key, conn, context, options \\ %{}) do
      # 1. Base 64 Decode
      # 2. Check for Token,
      # 3. If no match check for partial matches and log invalid attempt on any partial match, and for user.
      # 4. If match verify constraints are met. (Time Range, Access Attempts, etc.)
      # 5. If constraints failed return error status
      # 6. If constraints match return success status.

      case Base.url_decode64(token_key) do
        {:ok, value} ->
          {l,r} = Enum.split(:erlang.binary_to_list(value), 16)
          cond do
            length(l) == 16 && length(r) == 16 ->
              l_extract = UUID.binary_to_string!(:erlang.list_to_binary(l))
              r_extract = UUID.binary_to_string!(:erlang.list_to_binary(r))
              match = [{:active, true}, {:token, {l_extract, r_extract}}]
              # @TODO dynamic database selection.
              case (Noizu.SmartToken.V3.Database.Token.Table.match!(match) |> Amnesia.Selection.values) do
                nil -> {:error, :no_match}
                [] ->
                  flag_invalid_attempt({l_extract, r_extract}, conn, context, options)
                  {:error, :invalid}
                m when is_list(m) ->
                  m = Enum.map(m, &(&1.entity))
                  case validate(m, conn, context, options) do
                    {:ok, token} ->
                      update = Noizu.SmartToken.V3.Token.Entity.record_valid_access!(token, conn, options)
                      {:ok, update}
                    {:error, reason} ->
                      Noizu.SmartToken.V3.Token.Entity.record_invalid_access!(m, conn, options)
                      {:error, reason}
                  end
                _ -> {:error, :other}
              end
            true -> {:error, :encoding}
          end
        _ -> {:error, :base64}
      end
    end

    #-------------------------------------
    # flag_invalid_attempt/4
    #-------------------------------------
    def flag_invalid_attempt({_l_extract, _r_extract}, _conn, _context, _options) do
      # @TODO check for partial hit. and record malformed request for user.
      # @PRI-1
      :ok
    end

    #-------------------------------------
    # validate/4
    #-------------------------------------
    def validate(nil, _conn, _context, _options) do
      {:error, :invalid}
    end

    def validate([], _conn, _context, _options) do
      {:error, :invalid}
    end

    def validate([h|t], conn, context, options) do
      case Noizu.SmartToken.V3.Token.Entity.validate(h, conn, context, options) do
        {:ok, v} -> {:ok, v}
        _ -> validate(t, conn, context, options)
      end
    end

    #-------------------------------------
    # bind!/2
    #-------------------------------------
    def bind!(%Noizu.SmartToken.V3.Token.Entity{} = token, bindings, context, options \\ %{}) do
      token
      |> Noizu.SmartToken.V3.Token.Entity.bind(bindings, options)
      |> create!(context, options)
    end

  end


end
