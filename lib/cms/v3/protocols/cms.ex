#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.V3.CMS.Protocol do
  @fallback_to_any true

  def __cms__(ref, context, options)
  def __cms__!(ref, context, options)

  def __cms__(ref, property, context, options)
  def __cms__!(ref, property, context, options)

  def __cms_info__(ref, context, options)
  def __cms_info__!(ref, context, options)

  def __cms_info__(ref, property, context, options)
  def __cms_info__!(ref, property, context, options)

  def __set_article_info__(ref, update, context, options)
  def __set_article_info__!(ref, update, context, options)

  def __update_article_info__(ref, context, options)
  def __update_article_info__!(ref, context, options)

  def __init_article_info__(ref, context, options)
  def __init_article_info__!(ref, context, options)

  def aref(ref, context, options)

  def article(ref, context, options)
  def article!(ref, context, options)

  def article_info(ref, context, options)
  def article_info!(ref, context, options)

  def version(ref, context, options)
  def version!(ref, context, options)

  def revision(ref, context, options)
  def revision!(ref, context, options)

  def active_version(ref, context, options)
  def active_version!(ref, context, options)

  def active_revision(ref, context, options)
  def active_revision!(ref, context, options)

  def versioning_record?(ref, context, options)
  def versioning_record!(ref, context, options)

end # end defprotocol


defimpl Noizu.V3.CMS.Protocol, for: Any do
  defmacro __deriving__(module, _struct, _opts) do
    quote do
      defimpl Noizu.V3.CMS.Protocol, for: unquote(module) do
        def __cms__(_ref, _context, _options) do
          unquote(module).__cms__()
        end
        def __cms__!(_ref, _context, _options), do: unquote(module).__cms__()

        def __cms__(_ref, property, _context, _options), do: unquote(module).__cms__(property)
        def __cms__!(_ref, property, _context, _options), do: unquote(module).__cms__(property)

        def __cms_info__(ref, context, options), do: unquote(module).__cms_info__(ref, context, options)
        def __cms_info__!(ref, context, options), do: unquote(module).__cms_info__!(ref, context, options)

        def __cms_info__(ref, property, context, options), do: unquote(module).__cms_info__(ref, property, context, options)
        def __cms_info__!(ref, property, context, options), do: unquote(module).__cms_info__!(ref, property, context, options)

        def __set_article_info__(ref, update, context, options), do: unquote(module).__set_article_info__(ref, update, context, options)
        def __set_article_info__!(ref, update, context, options), do: unquote(module).__set_article_info__!(ref, update, context, options)

        def __update_article_info__(ref, context, options), do: unquote(module).__update_article_info__(ref, context, options)
        def __update_article_info__!(ref, context, options), do: unquote(module).__update_article_info__!(ref, context, options)

        def __init_article_info__(ref, context, options), do: unquote(module).__init_article_info__(ref, context, options)
        def __init_article_info__!(ref, context, options), do: unquote(module).__init_article_info__!(ref, context, options)

        def aref(ref, context, options), do: unquote(module).aref(ref, context, options)

        def article(ref, context, options), do: unquote(module).article(ref, context, options)
        def article!(ref, context, options), do: unquote(module).article!(ref, context, options)

        def article_info(ref, context, options), do: unquote(module).article_info(ref, context, options)
        def article_info!(ref, context, options), do: unquote(module).article_info!(ref, context, options)

        def version(ref, context, options), do: unquote(module).version(ref, context, options)
        def version!(ref, context, options), do: unquote(module).version!(ref, context, options)

        def revision(ref, context, options), do: unquote(module).revision(ref, context, options)
        def revision!(ref, context, options), do: unquote(module).revision!(ref, context, options)

        def active_version(ref, context, options), do: unquote(module).active_version(ref, context, options)
        def active_version!(ref, context, options), do: unquote(module).active_version!(ref, context, options)

        def active_revision(ref, context, options), do: unquote(module).active_revision(ref, context, options)
        def active_revision!(ref, context, options), do: unquote(module).active_revision!(ref, context, options)

        def versioning_record?(ref, context, options), do: unquote(module).versioning_record?(ref, context, options)
        def versioning_record!(ref, context, options), do: unquote(module).versioning_record!(ref, context, options)
      end
    end
  end

  def __cms__(_ref, _context, _options), do: nil
  def __cms__!(_ref, _context, _options), do: nil

  def __cms__(_ref, _property, _context, _options), do: nil
  def __cms__!(_ref, _property, _context, _options), do: nil

  def __cms_info__(_ref, _context, _options), do: nil
  def __cms_info__!(_ref, _context, _options), do: nil

  def __cms_info__(_ref, _property, _context, _options), do: nil
  def __cms_info__!(_ref, _property, _context, _options), do: nil

  def __set_article_info__(_ref, _update, _context, _options), do: nil
  def __set_article_info__!(_ref, _update, _context, _options), do: nil

  def __update_article_info__(_ref, _context, _options), do: nil
  def __update_article_info__!(_ref, _context, _options), do: nil

  def __init_article_info__(_ref, _context, _options), do: nil
  def __init_article_info__!(_ref, _context, _options), do: nil

  def aref(_ref, _context, _options), do: nil

  def article(_ref, _context, _options), do: nil
  def article!(_ref, _context, _options), do: nil

  def article_info(_ref, _context, _options), do: nil
  def article_info!(_ref, _context, _options), do: nil

  def version(_ref, _context, _options), do: nil
  def version!(_ref, _context, _options), do: nil

  def revision(_ref, _context, _options), do: nil
  def revision!(_ref, _context, _options), do: nil

  def active_version(_ref, _context, _options), do: nil
  def active_version!(_ref, _context, _options), do: nil

  def active_revision(_ref, _context, _options), do: nil
  def active_revision!(_ref, _context, _options), do: nil

  def versioning_record?(_ref, _context, _options), do: nil
  def versioning_record!(_ref, _context, _options), do: nil

end


defimpl Noizu.V3.CMS.Protocol, for: [BitString] do
  def __cms__(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__cms__(ref, context, options)
  def __cms__!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__cms__!(ref, context, options)

  def __cms__(ref, property, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__cms__(ref, property, context, options)
  def __cms__!(ref, property, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__cms__!(ref, property, context, options)

  def __cms_info__(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__cms_info__(ref, context, options)
  def __cms_info__!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__cms_info__!(ref, context, options)

  def __cms_info__(ref, property, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__cms_info__(ref, property, context, options)
  def __cms_info__!(ref, property, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__cms_info__!(ref, property, context, options)

  def __set_article_info__(ref, update, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__set_article_info__(ref, update, context, options)
  def __set_article_info__!(ref, update, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__set_article_info__!(ref, update, context, options)

  def __update_article_info__(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__update_article_info__(ref, context, options)
  def __update_article_info__!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__update_article_info__!(ref, context, options)

  def __init_article_info__(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__init_article_info__(ref, context, options)
  def __init_article_info__!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.__init_article_info__!(ref, context, options)

  def aref(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.aref(ref, context, options)

  def article(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.article(ref, context, options)
  def article!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.article!(ref, context, options)

  def article_info(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.article_info(ref, context, options)
  def article_info!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.article_info!(ref, context, options)

  def version(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.version(ref, context, options)
  def version!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.version!(ref, context, options)

  def revision(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.revision(ref, context, options)
  def revision!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.revision!(ref, context, options)

  def active_version(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.active_version(ref, context, options)
  def active_version!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.active_version!(ref, context, options)

  def active_revision(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.active_revision(ref, context, options)
  def active_revision!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.active_revision!(ref, context, options)

  def versioning_record?(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.versioning_record?(ref, context, options)
  def versioning_record!(ref, context, options), do: Noizu.ERP.ref(ref) |> Noizu.V3.CMS.Protocol.versioning_record!(ref, context, options)

end



defimpl Noizu.V3.CMS.Protocol, for: [Tuple] do
  def apply_action({:ref, m,_}, action, arguments) do
    cond do
      Kernel.function_exported?(m, action, length(arguments)) -> apply(m, action, arguments)
      :else -> nil
    end
  end
  def apply_action(_ref, _action, _arguments), do: nil

  def __cms__(ref, context, options), do: apply_action(ref, :__cms__, [])
  def __cms__!(ref, context, options), do: apply_action(ref, :__cms__!, [])

  def __cms__(ref, property, context, options), do: apply_action(ref, :__cms__, [property])
  def __cms__!(ref, property, context, options), do: apply_action(ref, :__cms__!, [property])

  def __cms_info__(ref, context, options), do: apply_action(ref, :__cms_info__, [ref, context, options])
  def __cms_info__!(ref, context, options), do: apply_action(ref, :__cms_info__!, [ref, context, options])

  def __cms_info__(ref, property, context, options), do: apply_action(ref, :__cms_info__, [ref, property, context, options])
  def __cms_info__!(ref, property, context, options), do: apply_action(ref, :__cms_info__!, [ref, property, context, options])

  def __set_article_info__(ref, update, context, options), do: apply_action(ref, :__set_article_info__, [ref, update, context, options])
  def __set_article_info__!(ref, update, context, options), do: apply_action(ref, :__set_article_info__!, [ref, update, context, options])

  def __update_article_info__(ref, context, options), do: apply_action(ref, :__update_article_info__, [ref, context, options])
  def __update_article_info__!(ref, context, options), do: apply_action(ref, :__update_article_info__!, [ref, context, options])

  def __init_article_info__(ref, context, options), do: apply_action(ref, :__init_article_info__, [ref, context, options])
  def __init_article_info__!(ref, context, options), do: apply_action(ref, :__init_article_info__!, [ref, context, options])

  def aref(ref, context, options), do: apply_action(ref, :aref, [ref, context, options])

  def article(ref, context, options), do: apply_action(ref, :article, [ref, context, options])
  def article!(ref, context, options), do: apply_action(ref, :article!, [ref, context, options])

  def article_info(ref, context, options), do: apply_action(ref, :article_info, [ref, context, options])
  def article_info!(ref, context, options), do: apply_action(ref, :article_info!, [ref, context, options])

  def version(ref, context, options), do: apply_action(ref, :version, [ref, context, options])
  def version!(ref, context, options), do: apply_action(ref, :version!, [ref, context, options])

  def revision(ref, context, options), do: apply_action(ref, :revision, [ref, context, options])
  def revision!(ref, context, options), do: apply_action(ref, :revision!, [ref, context, options])

  def active_version(ref, context, options), do: apply_action(ref, :active_version, [ref, context, options])
  def active_version!(ref, context, options), do: apply_action(ref, :active_version!, [ref, context, options])

  def active_revision(ref, context, options), do: apply_action(ref, :active_revision, [ref, context, options])
  def active_revision!(ref, context, options), do: apply_action(ref, :active_revision!, [ref, context, options])

  def versioning_record?({:ref, _m, {:version, {_identifier, _version}}}, _context, _options), do: true
  def versioning_record?({:ref, _m, {:revision, {_identifier, _version, _revision}}}, _context, _options), do:  true
  def versioning_record?(ref, context, options), do: apply_action(ref, :versioning_record?, [ref, context, options])

  def versioning_record!({:ref, _m, {:version, {_identifier, _version}}}, _context, _options), do: true
  def versioning_record!({:ref, _m, {:revision, {_identifier, _version, _revision}}}, _context, _options), do: true
  def versioning_record!(ref, context, options), do: apply_action(ref, :versioning_record!, [ref, context, options])

end
