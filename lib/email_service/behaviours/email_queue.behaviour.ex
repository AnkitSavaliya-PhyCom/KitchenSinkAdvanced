#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2022 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Noizu.EmailService.V3.EmailQueue.Behaviour do
  @callback queue!(email :: any, context :: any, options :: any) :: term
  @callback queue_failure!(email :: any, details :: any, context :: any, options :: any) :: term
end