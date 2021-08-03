defmodule Noizu.V3.CMS.Meta.ArticleType.Entity do

  defmodule Default do
    @revision_format ~r/^(.*)-(.*)@([0-9a-zA-Z][0-9a-zA-Z\.]*)-([0-9a-zA-Z]+)$/
    @version_format ~r/^(.*)-(.*)@([0-9a-zA-Z][0-9a-zA-Z\.]*)$/
    @article_format ~r/^(.*)-(.*)$/

    def __cms_info__(_m, _ref, _context, _options), do: []
    def __cms_info__!(_m, _ref, _context, _options), do: []

    def __cms_info__(_m, _ref, _property, _context, _options), do: nil
    def __cms_info__!(_m, _ref, _property, _context, _options), do: nil

    def __set_article_info__(_m, ref, update, _context, _options) do
      put_in(ref,[Access.key(:article_info)], update)
    end

    def __set_article_info__!(_m, ref, update, _context, _options) do
      put_in(ref,[Access.key(:article_info)], update)
    end

    def __update_article_info__(m, ref, context, options) do
      current_time = options[:current_time] || DateTime.utc_now()
      article_ref = Noizu.V3.CMS.Protocol.aref(ref, context, options)
      article_type = Noizu.V3.CMS.Protocol.__cms__(ref, :article_type, context, options)
      article_info = Noizu.V3.CMS.Protocol.article_info(ref, context, options) || struct(Noizu.V3.CMS.Protocol.__cms__(ref, :article_info, context, options), [])
      editor = options[:editor] || article_info.editor || context.caller
      status = options[:status] || article_info.status || :pending
      article_info = article_info.__struct__.update(article_info, [
        article: article_ref,
        article_type: article_type,
        manager: m,
        editor: editor,
        status: status,
        modified_on: current_time
      ], context, options)
      Noizu.V3.CMS.Protocol.__set_article_info__(ref, article_info, context, options)
    end
    def __update_article_info__!(m, ref, context, options) do
      current_time = options[:current_time] || DateTime.utc_now()
      article_ref = Noizu.V3.CMS.Protocol.aref(ref, context, options)
      article_type = Noizu.V3.CMS.Protocol.__cms__!(ref, :article_type, context, options)
      article_info = Noizu.V3.CMS.Protocol.article_info!(ref, context, options) || struct(Noizu.V3.CMS.Protocol.__cms__!(ref, :article_info, context, options), [])
      editor = cond do
                 options[:editor] == :existing -> article_info.editor
                 options[:editor] -> options[:editor]
                 article_info.editor -> article_info.editor
                 :else -> context.caller
               end
      status = options[:status] || article_info.status || :pending
      article_info = article_info.__struct__.update!(article_info, [
        article: article_ref,
        article_type: article_type,
        manager: m,
        editor: editor,
        status: status,
        modified_on: current_time
      ], context, options)
      Noizu.V3.CMS.Protocol.__set_article_info__!(ref, article_info, context, options)
    end

    def __init_article_info__(m, ref, context, options) do
      current_time = options[:current_time] || DateTime.utc_now()
      article_ref = Noizu.V3.CMS.Protocol.aref(ref, context, options)
      article_type = Noizu.V3.CMS.Protocol.__cms__(ref, :article_type, context, options)
      article_info = Noizu.V3.CMS.Protocol.article_info(ref, context, options) || struct(Noizu.V3.CMS.Protocol.__cms__(ref, :article_info, context, options), [])
      editor = cond do
                 options[:editor] == :existing -> article_info.editor
                 options[:editor] -> options[:editor]
                 article_info.editor -> article_info.editor
                 :else -> context.caller
               end
      status = options[:status] || article_info.status || :pending
      article_info = article_info.__struct__.overwrite(article_info, [
        article: article_ref,
        article_type: article_type,
        manager: m,
        editor: editor,
        status: status,
        modified_on: current_time
      ], context, options)
      Noizu.V3.CMS.Protocol.__set_article_info__(ref, article_info, context, options)
    end
    def __init_article_info__!(m, ref, context, options) do
      current_time = options[:current_time] || DateTime.utc_now()
      article_ref = Noizu.V3.CMS.Protocol.aref(ref, context, options)
      article_type = Noizu.V3.CMS.Protocol.__cms__!(ref, :article_type, context, options)
      article_info = Noizu.V3.CMS.Protocol.article_info!(ref, context, options) || struct(Noizu.V3.CMS.Protocol.__cms__!(ref, :article_info, context, options), [])
      editor = cond do
                 options[:editor] == :existing -> article_info.editor
                 options[:editor] -> options[:editor]
                 article_info.editor -> article_info.editor
                 :else -> context.caller
               end
      status = options[:status] || article_info.status || :pending
      article_info = article_info.__struct__.overwrite!(article_info, [
        article: article_ref,
        article_type: article_type,
        manager: m,
        editor: editor,
        status: status,
        modified_on: current_time
      ], context, options)
      Noizu.V3.CMS.Protocol.__set_article_info__!(ref, article_info, context, options)
    end


    def aref(_m, ref, _context, _options) do
      identifier = case ref.identifier do
                     {:revision, {_entity, id, _version_path, _revision_id}} -> id
                     {:version, {_entity, id, _version_path}} -> id
                     identifier when is_integer(identifier) -> identifier
                     identifier when is_atom(identifier) -> identifier
                     _ -> nil
                   end
      ref.__struct__.ref(identifier)
    end



    def bare_identifier(identifier) do
      case identifier do
        {:ref, _, ref} -> bare_identifier(ref)
        {:version, {_entity, aid, _version_path}} -> aid
        {:revision, {_entity, aid, _version_path, _rev}} -> aid
        aid when is_integer(aid) or is_atom(aid) -> aid
        :else -> nil
      end
    end


    def active_version(m, %{article_info: _article_info} = ref, context, options) do
      m.__cms_manager__().active_version(ref, context, options)
    end
    def active_version(m, {:ref, m, identifier} = ref, context, options) do
      aid = bare_identifier(identifier)
      cond do
        aid == nil -> nil
        :else ->
          active_version_table = Noizu.V3.CMS.Protocol.__cms__(ref, :active_version, context, options)
          case active_version_table.match([article: {:ref, :_, aid}]) |> Amnesia.Selection.values() do
            [av|_] -> av.version
            _ -> nil
          end
      end
    end


    def active_version!(m, %{article_info: _article_info} = ref, context, options) do
      m.__cms_manager__().active_version!(ref, context, options)
    end
    def active_version!(m, {:ref, m, identifier} = ref, context, options) do
      aid = bare_identifier(identifier)
      cond do
        aid == nil -> nil
        :else ->
          active_version_table = Noizu.V3.CMS.Protocol.__cms__!(ref, :active_version, context, options)
          case active_version_table.match!([article: {:ref, :_, aid}]) |> Amnesia.Selection.values() do
            [av|_] -> av.version
            _ -> nil
          end
      end
    end

    def active_revision(m, %{article_info: _article_info} = ref, context, options) do
      m.__cms_manager__().active_revision(ref, context, options)
    end
    def active_revision(m, {:ref, m, identifier} = ref, context, options) do
      aid = bare_identifier(identifier)
      cond do
        aid == nil -> nil
        :else ->
          active_version_table = Noizu.V3.CMS.Protocol.__cms__(ref, :active_version, context, options)
          active_revision_table = Noizu.V3.CMS.Protocol.__cms__(ref, :active_revision, context, options)
          case active_version_table.match([article: {:ref, :_, aid}]) |> Amnesia.Selection.values() do
            [av|_] ->
              cond do
                ar = active_revision_table.read(av.version) -> ar.revision
                :else -> nil
              end
              _ -> nil
          end
      end
    end

    def active_revision!(m, %{article_info: _article_info} = ref, context, options) do
      m.__cms_manager__().active_revision!(ref, context, options)
    end
    def active_revision!(m, {:ref, m, identifier} = ref, context, options) do
      aid = bare_identifier(identifier)
      cond do
        aid == nil -> nil
        :else ->
          active_version_table = Noizu.V3.CMS.Protocol.__cms__!(ref, :active_version, context, options)
          active_revision_table = Noizu.V3.CMS.Protocol.__cms__!(ref, :active_revision, context, options)
          case active_version_table.match!([article: {:ref, :_, aid}]) |> Amnesia.Selection.values() do
            [av|_] ->
              cond do
                ar = active_revision_table.read!(av.version) -> ar.revision
                :else -> nil
              end
            _ -> nil
          end
      end
    end

    def active_revision(_m, ref, version, context, options) do
      version = Noizu.ERP.ref(version)
      active_revision_table = Noizu.V3.CMS.Protocol.__cms__(ref, :active_revision, context, options)
      cond do
        ar = version && active_revision_table.read(version) -> ar.revision
        :else -> nil
      end
    end

    def active_revision!(_m, ref, version, context, options) do
      version = Noizu.ERP.ref(version)
      active_revision_table = Noizu.V3.CMS.Protocol.__cms__(ref, :active_revision, context, options)
      cond do
        ar = version && active_revision_table.read!(version) -> ar.revision
        :else -> nil
      end
    end

    def article_info(_m, %{article_info: article_info}, _context, _options), do: article_info
    def article_info(m, ref, _context, _options) do
      if entity = m.entity(ref), do: entity.article_info
    end

    def article_info!(_m, %{article_info: article_info}, _context, _options), do: article_info
    def article_info!(m, ref, _context, _options) do
      if entity = m.entity(ref), do: entity.article_info
    end

    def versioning_record?(_m, %{identifier: {:revision, {_entity, _identifier, _version, _revision}}}, _context, _options), do: true
    def versioning_record?(_m,  %{identifier: {:version, {_entity, _identifier, _version}}}, _context, _options), do: true
    def versioning_record?(_m, _ref, _context, _options), do: false

    def versioning_record!(_m, %{identifier: {:revision, {_entity, _identifier, _version, _revision}}}, _context, _options), do: true
    def versioning_record!(_m,  %{identifier: {:version, {_entity, _identifier, _version}}}, _context, _options), do: true
    def versioning_record!(_m, _ref, _context, _options), do: false


    def version(_m, ref, context, options) do
      if article_info = Noizu.V3.CMS.Protocol.article_info(ref, context, options) do
        article_info.version
      end
    end
    def version!(_m, ref, context, options) do
      if article_info = Noizu.V3.CMS.Protocol.article_info!(ref, context, options) do
        article_info.version
      end
    end

    def revision(_m, ref, context, options) do
      if article_info = Noizu.V3.CMS.Protocol.article_info(ref, context, options) do
        article_info.revision
      end
    end
    def revision!(_m, ref, context, options) do
      if article_info = Noizu.V3.CMS.Protocol.article_info!(ref, context, options) do
        article_info.revision
      end
    end

    #------------------------------
    # id_to_string
    #------------------------------
    def id_to_string(caller, identifier) do
      case identifier do
        nil -> nil
        {:revision, {e,i,v,r}} ->
          cond do
            i == nil -> {:error, {:unsupported, identifier}}
            !is_tuple(v) -> {:error, {:unsupported, identifier}}
            r == nil -> {:error, {:unsupported, identifier}}
            !(is_integer(r) || is_bitstring(r) || is_atom(r)) -> {:error, {:unsupported, identifier}}
            String.contains?("#{r}", ["-", "@"]) -> {:error, {:unsupported, identifier}}
            vp = caller.version_path_to_string(v) ->
              case caller.article_id_to_string(i) do
                {:ok, id} ->
                  article_subtype = e.sref_subtype()
                  {:ok, "{#{id}-#{article_subtype}@#{vp}-#{r}}"}
                _ -> {:error, {:unsupported, identifier}}
              end
            true -> {:error, {:unsupported, identifier}}
          end
        {:version, {e, i,v}} ->
          cond do
            i == nil -> {:error, {:unsupported, identifier}}
            !is_tuple(v) -> {:error, {:unsupported, identifier}}
            vp = caller.version_path_to_string(v) ->
              case caller.article_id_to_string(i) do
                {:ok, id} ->
                  article_subtype = e.sref_subtype()
                  {:ok, "{#{id}-#{article_subtype}@#{vp}}"}
                _ -> {:error, {:unsupported, identifier}}
              end
            true -> {:error, {:unsupported, identifier}}
          end
        _ ->
          case caller.article_id_to_string(identifier) do
            {:ok, v} ->
              article_subtype = caller.sref_subtype()
              {:ok, "{#{v}-#{article_subtype}}"}
            v -> v
          end
      end
    end

    #------------------------------
    # version_path_to_string/2
    #------------------------------
    def version_path_to_string(_caller, version_path) do
      v_l = Tuple.to_list(version_path)
      v_err = Enum.any?(v_l, fn(x) ->
        cond do
          x == nil -> true
          !(is_bitstring(x) || is_integer(x) || is_atom(x)) -> true
          String.contains?("#{x}", [".", "-", "@"]) -> true
          true -> false
        end
      end)
      cond do
        length(v_l) == 0 -> nil
        v_err -> nil
        true -> Enum.map(v_l, &("#{&1}")) |> Enum.join(".")
      end
    end

    #------------------------------
    # article_id_to_string
    #------------------------------
    @doc """
      override this if your entity type uses string values, nested refs, etc. for it's identifier.
    """
    def article_id_to_string(_caller, identifier) do
      cond do
        is_integer(identifier) -> {:ok, "#{identifier}"}
        is_atom(identifier) -> {:ok, "#{identifier}"}
        is_bitstring(identifier) -> {:ok, "#{identifier}"}
        true -> {:error, {:unsupported, identifier}}
      end
    end


    #------------------------------
    # string_to_id
    #------------------------------
    def string_to_id(_caller, nil), do: nil
    def string_to_id(caller, identifier) when is_bitstring(identifier) do
      case identifier do
        "ref." <> _ -> {:error, {:unsupported, identifier}}
        _ ->
          cond do
            Regex.match?(@revision_format, identifier) ->
              case Regex.run(@revision_format, identifier) do
                [_, identifier, type, version, revision] ->
                  case caller.article_string_to_id(identifier) do
                    {:ok, i} ->
                      version_path = String.split(version, ".")
                                     |> Enum.map(
                                          fn(x) ->
                                            case Integer.parse(x) do
                                              {v, ""} -> v
                                              _ -> x
                                            end
                                          end)
                                     |> List.to_tuple()
                      revision = case Integer.parse(revision) do
                                   {v, ""} -> v
                                   _ -> revision
                                 end
                      type = caller.__cms_manager__().sref_subtype_module(type)
                      {:revision, {type, i, version_path, revision}}
                    _ -> {:error, {:unsupported, identifier}}
                  end
                _ ->  {:error, {:unsupported, identifier}}
              end

            Regex.match?(@version_format, identifier) ->
              case Regex.run(@version_format, identifier) do
                [_, identifier, type, version] ->
                  case caller.article_string_to_id(identifier) do
                    {:ok, i} ->
                      version_path = String.split(version, ".")
                                     |> Enum.map(
                                          fn(x) ->
                                            case Integer.parse(x) do
                                              {v, ""} -> v
                                              _ -> x
                                            end
                                          end)
                                     |> List.to_tuple()
                      type = caller.__cms_manager__().sref_subtype_module(type)
                      {:version, {type, i, version_path}}
                    _ -> {:error, {:unsupported, identifier}}
                  end
                _ ->  {:error, {:unsupported, identifier}}
              end

            Regex.match?(@article_format, identifier) ->
              case Regex.run(@article_format, identifier) do
                [_, identifier, type] ->
                  case caller.article_string_to_id(identifier) do
                    {:ok, i} ->
                      type = caller.__cms_manager__().sref_subtype_module(type)
                      {:article, {type, i}}
                    _ -> {:error, {:unsupported, identifier}}
                  end
                _ ->  {:error, {:unsupported, identifier}}
              end

            true ->
              caller.article_string_to_id(identifier)
          end
      end
    end
    def string_to_id(_caller, i), do: {:error, {:unsupported, i}}


    #------------------------------
    # article_string_to_id
    #------------------------------
    @doc """
      override this if your entity type uses string values, nested refs, etc. for it's identifier.
    """
    def article_string_to_id(_caller, nil), do: nil
    def article_string_to_id(_caller, identifier) when is_bitstring(identifier) do
      case identifier do
        "ref." <> _ -> {:error, {:unsupported, identifier}}
        _ ->
          case Integer.parse(identifier) do
            {id, ""} -> {:ok, id}
            v -> {:error, {:parse, v}}
          end
      end
    end
    def article_string_to_id(_caller, i), do: {:error, {:unsupported, i}}



  end

  defmacro __using__(_options \\ nil) do
    nil
  end

  def pre_defstruct(_options) do
    quote do
      @__nzdo__derive Noizu.V3.CMS.Protocol
    end
  end

  def post_defstruct(options) do
    options = Macro.expand(options, __ENV__)
    article_type = options[:article_type] || :default
    quote do
      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      alias Noizu.V3.CMS.Meta.ArticleType.Entity.Default, as: Provider
      def __cms_manager__(), do:  @__nzdo__poly_base.__cms_manager__()

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms__(), do: put_in(@__nzdo__poly_base.__cms__(), [:article_type], unquote(article_type))
      def __cms__!(), do: put_in(@__nzdo__poly_base.__cms__!(), [:article_type], unquote(article_type))

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms__(:article_type), do: unquote(article_type)
      def __cms__(property), do: @__nzdo__poly_base.__cms__(property)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms__!(:article_type), do: unquote(article_type)
      def __cms__!(property), do: @__nzdo__poly_base.__cms__!(property)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms_info__(ref, context, options), do: Provider.__cms_info__(__MODULE__, ref, context, options)
      def __cms_info__!(ref, context, options), do: Provider.__cms_info__!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms_info__(ref, property, context, options), do: Provider.__cms_info__(__MODULE__, ref, property, context, options)
      def __cms_info__!(ref, property, context, options), do: Provider.__cms_info__!(__MODULE__, ref, property, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __set_article_info__(ref, update, context, options), do: Provider.__set_article_info__(__MODULE__, ref, update, context, options)
      def __set_article_info__!(ref, update, context, options), do: Provider.__set_article_info__!(__MODULE__, ref, update, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __update_article_info__(ref, context, options), do: Provider.__update_article_info__(__MODULE__, ref, context, options)
      def __update_article_info__!(ref, context, options), do: Provider.__update_article_info__!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __init_article_info__(ref, context, options), do: Provider.__init_article_info__(__MODULE__, ref, context, options)
      def __init_article_info__!(ref, context, options), do: Provider.__init_article_info__!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def aref(ref, context, options), do: Provider.aref(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def article_info(ref, context, options), do: Provider.article_info(__MODULE__, ref, context, options)
      def article_info!(ref, context, options), do: Provider.article_info!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def versioning_record?(ref, context, options), do: Provider.versioning_record?(__MODULE__, ref, context, options)
      def versioning_record!(ref, context, options), do: Provider.versioning_record!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def active_version(ref, context, options), do: Provider.active_version(__MODULE__, ref, context, options)
      def active_version!(ref, context, options), do: Provider.active_version!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def active_revision(ref, context, options), do: Provider.active_revision(__MODULE__, ref, context, options)
      def active_revision!(ref, context, options), do: Provider.active_revision!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def active_revision(ref, version, context, options), do: Provider.active_revision(__MODULE__, ref, version, context, options)
      def active_revision!(ref, version, context, options), do: Provider.active_revision!(__MODULE__, ref, version, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def version(ref, context, options), do: Provider.version(__MODULE__, ref, context, options)
      def version!(ref, context, options), do: Provider.version!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def revision(ref, context, options), do: Provider.revision(__MODULE__, ref, context, options)
      def revision!(ref, context, options), do: Provider.revision!(__MODULE__, ref, context, options)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def version_path_to_string(version_path), do: Provider.version_path_to_string(__MODULE__, version_path)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def article_id_to_string(identifier), do: Provider.article_id_to_string(__MODULE__, identifier)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def id_to_string(_type, identifier), do: Provider.id_to_string(__MODULE__, identifier)
      def id_to_string(identifier), do: Provider.id_to_string(__MODULE__, identifier)


      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def string_to_id(_type, identifier), do: Provider.string_to_id(__MODULE__, identifier)
      def string_to_id(identifier), do: Provider.string_to_id(__MODULE__, identifier)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def article_string_to_id(identifier), do: Provider.article_string_to_id(__MODULE__, identifier)

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def ref("ref.#{@__nzdo__sref}{" <> id) do
        identifier = case string_to_id(String.slice(id, 0..-2)) do
                       {:ok, v} -> v
                       {:error, _} -> nil
                       v -> v
                     end
        case identifier do
          {:revision, {type, aid, version, revision}} -> {:ref, type, identifier}
          {:version, {type, aid, version}} -> {:ref, type, identifier}
          {:article, {type, aid}} -> {:ref, type, aid}
          _ -> nil
        end
      end
      def ref(ref), do: super(ref)


      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      defoverridable [
        __cms_manager__: 0,
        __cms__: 0,
        __cms__: 1,
        __cms_info__: 3,
        __cms_info__!: 3,
        __cms_info__: 4,
        __cms_info__!: 4,

        __set_article_info__: 4,
        __set_article_info__!: 4,

        __update_article_info__: 3,
        __update_article_info__!: 3,

        __init_article_info__: 3,
        __init_article_info__!: 3,

        aref: 3,

        article_info: 3,
        article_info!: 3,

        versioning_record?: 3,
        versioning_record!: 3,

        active_version: 3,
        active_version!: 3,

        active_revision: 3,
        active_revision!: 3,

        active_revision: 4,
        active_revision!: 4,

        version_path_to_string: 1,
        article_id_to_string: 1,
        id_to_string: 1,
        id_to_string: 2,
        string_to_id: 1,
        string_to_id: 2,
        article_string_to_id: 1,
        ref: 1,
      ]
    end
  end

  defmacro __before_compile__(_) do
    nil
  end

  def __after_compile__(_env, _bytecode) do
    nil
  end
end
