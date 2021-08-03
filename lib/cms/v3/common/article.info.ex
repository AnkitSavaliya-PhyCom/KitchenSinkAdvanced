#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.V3.CMS.Article.Info do
  use Noizu.SimpleObject
  @vsn 1.0
  Noizu.SimpleObject.noizu_struct() do
    internal_field :article
    internal_field :article_type
    internal_field :manager

    internal_field :name
    internal_field :description
    internal_field :note

    internal_field :parent
    internal_field :version
    internal_field :revision

    internal_field :tags
    internal_field :editor
    internal_field :status

    internal_field :time_stamp, nil, Noizu.Scaffolding.V3.TimeStamp.PersistenceStrategy
  end

  def overwrite_field(:time_stamp = field, source, current, _context, options) do
    cond do
      is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
      is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
      modified_on = source[:modified_on] ->
        current && %Noizu.Scaffolding.V3.TimeStamp{current| modified_on: modified_on} || Noizu.Scaffolding.V3.TimeStamp.new(modified_on)
      :else ->
        modified_on = options[:current_time] || DateTime.utc_now()
        current && %Noizu.Scaffolding.V3.TimeStamp{current| modified_on: modified_on} || Noizu.Scaffolding.V3.TimeStamp.new(modified_on)
    end
  end
  def overwrite_field(field, source, current, _context, _options) do
    cond do
      is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
      is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
      :else -> current
    end
  end



  def update_field(:editor = field, source, current, context, options) do
    source[field] || options[:editor] || current || context.caller
  end
  def update_field(:status = field, source, current, context, options) do
    overwrite_field(field, source, current, context, options)
  end
  def update_field(:time_stamp = field, source, current, _context, options) do
    cond do
      is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
      is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
      modified_on = source[:modified_on] ->
        current && %Noizu.Scaffolding.V3.TimeStamp{current| modified_on: modified_on} || Noizu.Scaffolding.V3.TimeStamp.new(modified_on)
      :else ->
        modified_on = options[:current_time] || DateTime.utc_now()
        current && %Noizu.Scaffolding.V3.TimeStamp{current| modified_on: modified_on} || Noizu.Scaffolding.V3.TimeStamp.new(modified_on)
    end
  end
  def update_field(field, source, current, _context, _options) do
    cond do
      current -> current
      is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
      is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
      :else -> nil
    end
  end

  def overwrite!(article_info, update, context, options), do: overwrite(article_info, update, context, options)
  def overwrite(article_info, update, context, options) do
    Enum.reduce(Map.from_struct(article_info), article_info, fn({field, current}, acc) ->
      put_in(acc, [Access.key(field)], overwrite_field(field, update, current, context, options))
    end)
  end


  def update!(article_info, update, context, options), do: update(article_info, update, context, options)
  def update(article_info, update, context, options) do
    Enum.reduce(Map.from_struct(article_info), article_info, fn({field, current}, acc) ->
      put_in(acc, [Access.key(field)], update_field(field, update, current, context, options))
    end)
  end

end
