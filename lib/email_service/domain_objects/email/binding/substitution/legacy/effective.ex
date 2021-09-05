#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2020 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.EmailService.V3.Email.Binding.Substitution.Legacy.Effective do
  @vsn 1.0
  #alias Noizu.EmailService.V3.Email.Binding.Substitution.Dynamic.Selector
  #alias Noizu.EmailService.V3.Email.Binding.Substitution.Dynamic.Section
  #alias Noizu.EmailService.V3.Email.Binding.Substitution.Dynamic.Formula
  @type t :: %__MODULE__{
               bind: [String.t],
               bound: Map.t,
               unbound: %{:optional => [String.t], :required => [String.t]},
               outcome: tuple | :ok,
               meta: Map.t,
               vsn: float,
             }

  defstruct [
    bind: [],
    bound: %{},
    unbound: %{
      optional: [],
      required: []
    },
    outcome: :ok,
    meta: %{},
    vsn: @vsn
  ]

end
