defmodule Noizu.V3.CMS.Meta.ArticleType.Entity do

  defmodule Default do
    def __cms_info__(m, ref, _context, _options), do: []
    def __cms_info__!(m, ref, _context, _options), do: []

    def __cms_info__(m, ref, property, _context, _options), do: nil
    def __cms_info__!(m, ref, property, _context, _options), do: nil

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
                     {:revision, {id, _version_path, _revision_id}} -> id
                     {:version, {id, _version_path}} -> id
                     identifier when is_integer(identifier) -> identifier
                     identifier when is_atom(identifier) -> identifier
                     _ -> nil
                   end
      ref.__struct__.ref(identifier)
    end



    def bare_identifier(identifier) do
      case identifier do
        {:version, {aid, _version_path}} -> aid
        {:revision, {aid, _version_path, _rev}} -> aid
        aid when is_integer(aid) or is_atom(aid) -> aid
        :else -> nil
      end
    end


    def active_version(m, %{article_info: article_info} = ref, context, options) do
      m.__cms_manager__().active_version(ref, context, options)
    end
    def active_version(m, {:ref, m, identifier}, context, options) do
      aid = bare_identifier(identifier)
      cond do
        aid == nil -> nil
        :else ->
          case Noizu.V3.CMS.Database.Article.Active.Version.Table.match([article: {:ref, :_, aid}]) |> Amnesia.Selection.values() do
            [av|_] -> av.version
            _ -> nil
          end
      end
    end


    def active_version!(m, %{article_info: article_info} = ref, context, options) do
      m.__cms_manager__().active_version!(ref, context, options)
    end
    def active_version!(m, {:ref, m, identifier}, context, options) do
      aid = bare_identifier(identifier)
      cond do
        aid == nil -> nil
        :else ->
          case Noizu.V3.CMS.Database.Article.Active.Version.Table.match!([article: {:ref, :_, aid}]) |> Amnesia.Selection.values() do
            [av|_] -> av.version
            _ -> nil
          end
      end
    end



    def active_revision(m, %{article_info: article_info} = ref, context, options) do
      m.__cms_manager__().active_revision(ref, context, options)
    end
    def active_revision(m, {:ref, m, identifier}, context, options) do
      aid = bare_identifier(identifier)
      cond do
        aid == nil -> nil
        :else ->
          case Noizu.V3.CMS.Database.Article.Active.Version.Table.match([article: {:ref, :_, aid}]) |> Amnesia.Selection.values() do
            [av|_] ->
              cond do
                ar = Noizu.V3.CMS.Database.Article.Active.Version.Revision.Table.read(av.version) -> ar.revision
                :else -> nil
              end
              _ -> nil
          end
      end
    end

    def active_revision!(m, %{article_info: article_info} = ref, context, options) do
      m.__cms_manager__().active_revision!(ref, context, options)
    end
    def active_revision!(m, {:ref, m, identifier}, context, options) do
      aid = bare_identifier(identifier)
      cond do
        aid == nil -> nil
        :else ->
          case Noizu.V3.CMS.Database.Article.Active.Version.Table.match!([article: {:ref, :_, aid}]) |> Amnesia.Selection.values() do
            v = [av|_] ->
              cond do
                ar = Noizu.V3.CMS.Database.Article.Active.Version.Revision.Table.read!(av.version) -> ar.revision
                :else -> nil
              end
            v -> nil
          end
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

    def versioning_record?(_m, %{identifier: {:revision, {_identifier, _version, _revision}}}, _context, _options), do: true
    def versioning_record?(_m,  %{identifier: {:version, {_identifier, _version}}}, _context, _options), do: true
    def versioning_record?(_m, _ref, _context, _options), do: false

    def versioning_record!(_m, %{identifier: {:revision, {_identifier, _version, _revision}}}, _context, _options), do: true
    def versioning_record!(_m,  %{identifier: {:version, {_identifier, _version}}}, _context, _options), do: true
    def versioning_record!(_m, _ref, _context, _options), do: false

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
    macro_file = __ENV__.file
    quote do
      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      alias Noizu.V3.CMS.Meta.ArticleType.Entity.Default, as: Provider
      def __cms_manager__(), do:  @__nzdo__poly_base.__cms_manager__()

      @file unquote(__ENV__.file) <> "(#{unquote(__ENV__.line)})"
      def __cms__(), do: put_in(@__nzdo__poly_base.__cms__(), [:article_type], unquote(article_type))
      def __cms__(), do: put_in(@__nzdo__poly_base.__cms__!(), [:article_type], unquote(article_type))

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
