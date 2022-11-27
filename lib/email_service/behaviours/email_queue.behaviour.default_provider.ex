#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2022 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Noizu.EmailService.V3.EmailQueue.Behaviour.DefaultProvider do
  alias Noizu.EmailService.V3.Email.Queue


  def queue!(email, context, options \\ nil) do
    with {:ok, queued_email} <- Queue.Repo.queue!(email, context) do
      spawn(fn -> Noizu.V3.Proto.EmailServiceQueue.attempt_send(queued_email, context, options) end)
      {:ok, queued_email}
    end
  end
  
  def queue_failure!(email, details, context, options \\ nil) do
    Queue.Repo.queue_failed!(email, details, context)
  end
  
  
end