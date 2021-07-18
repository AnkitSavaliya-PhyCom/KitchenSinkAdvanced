defmodule Noizu.V3.CMS.Meta.ArticleType.Repo do

  defmacro __using__(options \\ nil) do
    quote do
      Module.register_attribute(__MODULE__, :cms_article_manager, accumulate: false)
    end
  end

  def pre_defstruct(options) do
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



      #------------------------------------------
      # Create - layer_create
      #------------------------------------------
      def layer_create(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{schema: Noizu.V3.CMS.ArticleType.Persistence} = _layer, entity, _context, _options) do
        entity = %{entity| identifier: {:ref, Noizu.V3.CMS.Version.Entity, {1,2,3}}}
        IO.puts "CMS LAYER CREATE| #{inspect entity}"
        entity
      end
      def layer_create(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{} = layer, entity, context, options) do
        super(layer, entity, context, options)
      end

      def layer_create!(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{schema: Noizu.V3.CMS.ArticleType.Persistence} = _layer, entity, _context, _options) do
        entity = %{entity| identifier: {:ref, Noizu.V3.CMS.Version.Entity, {1,2,3}}}
        IO.puts "CMS LAYER CREATE!| #{inspect entity}"
        entity
      end
      def layer_create!(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{} = layer, entity, context, options) do
        super(layer, entity, context, options)
      end


      #------------------------------------------
      # Update - layer_update
      #------------------------------------------
      def layer_update(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{schema: Noizu.V3.CMS.ArticleType.Persistence} = _layer, entity, _context, _options) do
        IO.puts "CMS LAYER UPDATE"
        entity
      end
      def layer_update(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{} = layer, entity, context, options) do
        super(layer, entity, context, options)
      end

      def layer_update!(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{schema: Noizu.V3.CMS.ArticleType.Persistence} = _layer, entity, _context, _options) do
        IO.puts "CMS LAYER UPDATE"
        entity
      end
      def layer_update!(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{} = layer, entity, context, options) do
        super(layer, entity, context, options)
      end


      #------------------------------------------
      # Update - layer_delete
      #------------------------------------------
      def layer_delete(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{schema: Noizu.V3.CMS.ArticleType.Persistence} = _layer, entity, _context, _options) do
        IO.puts "CMS LAYER UPDATE"
        entity
      end
      def layer_delete(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{} = layer, entity, context, options) do
        super(layer, entity, context, options)
      end

      def layer_delete!(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{schema: Noizu.V3.CMS.ArticleType.Persistence} = _layer, entity, _context, _options) do
        IO.puts "CMS LAYER UPDATE"
        entity
      end
      def layer_delete!(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{} = layer, entity, context, options) do
        super(layer, entity, context, options)
      end


      #------------------------------------------
      # Update - layer_get
      #------------------------------------------
      def layer_get(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{schema: Noizu.V3.CMS.ArticleType.Persistence} = _layer, entity, _context, _options) do
        IO.puts "CMS LAYER GET"
        entity
      end
      def layer_get(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{} = layer, entity, context, options) do
        super(layer, entity, context, options)
      end

      def layer_get!(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{schema: Noizu.V3.CMS.ArticleType.Persistence} = _layer, entity, _context, _options) do
        IO.puts "CMS LAYER GET"
        entity
      end
      def layer_get!(%Noizu.Scaffolding.V3.Schema.PersistenceLayer{} = layer, entity, context, options) do
        super(layer, entity, context, options)
      end





      defoverridable [
        __cms__: 0,
        __cms__: 1,
        __cms_article__: 3,
        __cms_article__: 4,
        __cms_article__!: 3,
        __cms_article__!: 4,

        layer_create: 4,
        layer_create!: 4,

        layer_update: 4,
        layer_update!: 4,

        layer_delete: 4,
        layer_delete!: 4,

        layer_get: 4,
        layer_get!: 4,

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
