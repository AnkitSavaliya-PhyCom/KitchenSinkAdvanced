#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.MarkdownField do
  @type t :: %__MODULE__{
               markdown: String.t,
               html: String.t | nil,
               generated_on: integer | nil,
             }

  defstruct [
    markdown: nil,
    html: nil,
    generated_on: nil,
  ]

  def new(markdown, options \\ []) do
    %__MODULE__{
      markdown: markdown,
      html: Markdown.to_html(markdown, options),
      generated_on: (options[:current_time] && DateTime.to_unix(options[:current_time]) || :os.system_time(:second))
    }
  end

  def compress(%__MODULE__{} = entity), do: {:markdown, entity.markdown}
  def expand({:markdown, markdown}), do: %__MODULE__{markdown: markdown}
  def render(%__MODULE__{} = entity, options \\ []) do
    %__MODULE__{
      markdown: entity.markdown,
      html: Markdown.to_html(entity.markdown, options),
      generated_on: (options[:current_time] && DateTime.to_unix(options[:current_time]) || :os.system_time(:second))
    }
  end

end # end defmodule
