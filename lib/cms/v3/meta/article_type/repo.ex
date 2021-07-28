defmodule Noizu.V3.CMS.Meta.ArticleType.Repo do

  defmacro __using__(_options \\ nil) do
    quote do
      Module.register_attribute(__MODULE__, :cms_article_manager, accumulate: false)
    end
  end

  def pre_defstruct(_options) do
    quote do
      Module.put_attribute(__MODULE__, :__nzdo__article_cms_manager, Module.concat([@__nzdo__poly_base, CMS]))
    end
  end

  def post_defstruct(_options) do
    quote do
      def __cms_manager__(), do: @__nzdo__poly_base.__cms_manager__()

      def __cms__(), do: @__nzdo__poly_base.__cms__()
      def __cms__(property), do: @__nzdo__poly_base.__cms__(property)

      def __cms_article__(ref, context, options), do: @__nzdo__poly_base.__cms_article__(ref, context, options)
      def __cms_article__!(ref, context, options), do: @__nzdo__poly_base.__cms_article__!(ref, context, options)

      def __cms_article__(ref, property, context, options), do: @__nzdo__poly_base.__cms_article__(ref, property, context, options)
      def __cms_article__!(ref, property, context, options), do: @__nzdo__poly_base.__cms_article__!(ref, property, context, options)


      def pre_create_callback(entity, context, options) do
        entity = super(entity, context, options)
        versioning_record? = Noizu.V3.CMS.Protocol.versioning_record?(entity, context, options)
        options_a = put_in(options, [:nested_create], true)

        # AutoGenerate Identifier if not set, check for already existing record.
        entity = cond do
                   options[:nested_create] -> entity
                   get(entity.identifier, Noizu.ElixirCore.CallingContext.system(context), options_a) ->
                     # @todo if !is_version_record? we should specifically scan for any matching revisions.
                     throw "[Create Exception] Record Exists: #{Noizu.ERP.sref(entity)}"
                   :else -> entity
                 end

        if versioning_record? do
          entity
          |> Noizu.V3.CMS.Protocol.update_article_info(context, options_a)
          |> __cms_manager__().populate_version(context, options_a)
        else
          # 5. Prepare Version and Revision, modify identifier.
          entity
          |>  Noizu.V3.CMS.Protocol.init_article_info(context, options_a)
          |> __cms_manager__().initialize_version(context, options_a)
        end
      end

      def pre_create_callback!(entity, context, options) do
        entity = super(entity, context, options)
        versioning_record? = Noizu.V3.CMS.Protocol.versioning_record!(entity, context, options)
        options_a = put_in(options, [:nested_create], true)

        # AutoGenerate Identifier if not set, check for already existing record.
        entity = cond do
                   options[:nested_create] -> entity
                   get!(entity.identifier, Noizu.ElixirCore.CallingContext.system(context), options_a) ->
                     # @todo if !is_version_record? we should specifically scan for any matching revisions.
                     throw "[Create Exception] Record Exists: #{Noizu.ERP.sref(entity)}"
                   :else -> entity
                 end

        if versioning_record? do
          entity
          |> Noizu.V3.CMS.Protocol.update_article_info!(context, options_a)
          |> __cms_manager__().populate_version!(context, options_a)
        else
          # 5. Prepare Version and Revision, modify identifier.
          entity
          |> Noizu.V3.CMS.Protocol.init_article_info!(context, options_a)
          |> __cms_manager__().initialize_version!(context, options_a)
        end
      end

      def get(ref, context, options \\ nil) do
        try do
          identifier = cond do
                         Kernel.match?({:revision, {_id, _version_path, _revision_id}}, ref) ->
                           ref
                         Kernel.match?({:version, {_id, _version_path}}, ref) ->
                           {:version, {id, version_path}} = ref
                           cms_ref = __entity__.ref(id)
                           version = __cms_manager__().__cms_version__().__entity__().ref({cms_ref, version_path})
                           active_revision = Noizu.V3.CMS.Protocol.__cms_article__(version, :active_revision, context, options)
                           __cms_manager__().revision_to_id(active_revision)
                         :else ->
                           cms_ref = __entity__.ref(ref)
                           active_revision = Noizu.V3.CMS.Protocol.__cms_article__(cms_ref, :active_revision, context, options)
                           __cms_manager__().revision_to_id(active_revision)
                       end
            super(identifier, context, options)
        rescue e -> {:error, e}
        catch e -> {:error, e}
        end
      end

      def get!(ref, context, options \\ nil) do
        try do
          identifier = cond do
                         Kernel.match?({:revision, {_id, _version_path, _revision_id}}, ref) ->
                           ref
                         Kernel.match?({:version, {_id, _version_path}}, ref) ->
                           {:version, {id, version_path}} = ref
                           cms_ref = __entity__.ref(id)
                           version = __cms_manager__().__cms_version__().__entity__().ref({cms_ref, version_path})
                           active_revision = Noizu.V3.CMS.Protocol.__cms_article__!(version, :active_revision, context, options)
                           __cms_manager__().revision_to_id(active_revision)
                         :else ->
                           cms_ref = __entity__.ref(ref)
                           active_revision = Noizu.V3.CMS.Protocol.__cms_article__!(cms_ref, :active_revision, context, options)
                           __cms_manager__().revision_to_id(active_revision)
                       end
          super(identifier, context, options)
        rescue e -> {:error, e}
        catch e -> {:error, e}
        end
      end

      def pre_update_callback(entity, context, options) do
        options_a = put_in(options, [:nested_update], true)
        if (entity.identifier == nil), do: throw "Identifier not set"
        if (!Noizu.V3.CMS.Proto.versioning_record?(entity, context, options)), do: throw "#{entity.__struct__} entities may only be persisted using cms revision ids"
        super(entity, context, options)
        |> Noizu.V3.CMS.Protocol.update_article_info(context, options_a)
        |> __cms_manager__().populate_version(context, options_a)
      end

      def pre_update_callback!(entity, context, options) do
        options_a = put_in(options, [:nested_update], true)
        if (entity.identifier == nil), do: throw "Identifier not set"
        if (!Noizu.V3.CMS.Proto.versioning_record!(entity, context, options)), do: throw "#{entity.__struct__} entities may only be persisted using cms revision ids"
        super(entity, context, options)
        |> Noizu.V3.CMS.Protocol.update_article_info!(context, options_a)
        |> __cms_manager__().populate_version!(context, options_a)
      end

      def pre_delete_callback(entity, context, options) do
        if entity.identifier == nil, do: throw(:identifier_not_set)

        # Active Revision Check
        entity = cond do
                   options[:bookkeeping] == :disabled -> entity
                   :else ->
                     article_revision = Noizu.V3.CMS.__cms_article__(entity, :revision, context, options)
                                        |> Noizu.ERP.ref()
                     active_revision = Noizu.V3.CMS.__cms_article__(entity, :active_revision, context, options)
                                       |> Noizu.ERP.ref()
                     cond do
                       !article_revision -> throw :article_revision_not_found
                       article_revision == active_revision -> throw :active_revision
                       :else ->
                         active_version = case active_revision do
                                            {:ref, _, {article_version, _revision}} -> article_version
                                            _ -> nil
                                          end
                         case article_revision do
                           {:ref, _, {article_version, _revision}} ->
                             cond do
                               article_version == active_version -> entity
                               article_revision == Noizu.ERP.ref(Noizu.V3.CMS.__cms_article__(article_version, :active_revision, context, options)) ->
                                 throw :active_revision
                               :else -> entity
                             end
                           _ -> entity
                         end
                     end
                 end
        super(entity, context, options)
      end

      def pre_delete_callback!(entity, context, options) do
        if entity.identifier == nil, do: throw(:identifier_not_set)

        # Active Revision Check
        entity = cond do
                   options[:bookkeeping] == :disabled -> entity
                   :else ->
                     article_revision = Noizu.V3.CMS.__cms_article__!(entity, :revision, context, options)
                                        |> Noizu.ERP.ref()
                     active_revision = Noizu.V3.CMS.__cms_article__!(entity, :active_revision, context, options)
                                       |> Noizu.ERP.ref()
                     cond do
                       !article_revision -> throw :article_revision_not_found
                       article_revision == active_revision -> throw :active_revision
                       :else ->
                         active_version = case active_revision do
                                            {:ref, _, {article_version, _revision}} -> article_version
                                            _ -> nil
                                          end
                         case article_revision do
                           {:ref, _, {article_version, _revision}} ->
                             cond do
                               article_version == active_version -> entity
                               article_revision == Noizu.ERP.ref(Noizu.V3.CMS.__cms_article__!(article_version, :active_revision, context, options)) ->
                                 throw :active_revision
                               :else -> entity
                             end
                           _ -> entity
                         end
                     end
                 end
        super(entity, context, options)
      end

      defoverridable [
        __cms__: 0,
        __cms__: 1,
        __cms_article__: 3,
        __cms_article__: 4,
        __cms_article__!: 3,
        __cms_article__!: 4,

      # Elixir Scaffolding Updates
        pre_create_callback: 3,
        pre_create_callback!: 3,
        get: 2,
        get: 3,
        get!: 2,
        get!: 3,
        pre_update_callback: 3,
        pre_update_callback!: 3,
        pre_delete_callback: 3,
        pre_delete_callback!: 3,
      ]
    end
  end

  defmacro __before_compile__(_) do
    quote do

    end
  end

  def __after_compile__(_env, _bytecode) do
    nil
  end
end
