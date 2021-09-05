defmodule Noizu.V3.CMS.ArticleType do

  defmodule Persistence do
    def database(), do: Noizu.V3.CMS.ArticleType.Persistence
    def metadata(), do: %Noizu.AdvancedScaffolding.Schema.Metadata.Other{repo: __MODULE__, database: __MODULE__, type: :cms}
  end

  defmacro __using__(options \\ []) do
    options = Macro.expand(options, __ENV__)
    options = update_in(options, [:extension_implementation], &(&1 || Noizu.V3.CMS.Meta.ArticleType.Base))
    quote do
      use Noizu.DomainObject, unquote(options)
    end
  end

  #--------------------------------------------
  # article_cms_manager
  #--------------------------------------------
  defmacro article_cms_manager(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    quote do
      use Noizu.V3.CMS.Meta.ArticleType.CMS, unquote(options)
      unquote(block)
      @before_compile Noizu.V3.CMS.Meta.ArticleType.CMS
    end
  end


  #--------------------------------------------
  # article_entity
  #--------------------------------------------
  defmacro article_entity(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    options = update_in(options, [:extension_implementation], &(&1 || Noizu.V3.CMS.Meta.ArticleType.Entity))
    Noizu.AdvancedScaffolding.Internal.DomainObject.Entity.__noizu_entity__(__CALLER__, options, block)
  end

  #--------------------------------------------
  # article_repo
  #--------------------------------------------
  defmacro article_repo(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    options = update_in(options, [:extension_implementation], &(&1 || Noizu.V3.CMS.Meta.ArticleType.Repo))
    Noizu.AdvancedScaffolding.Internal.DomainObject.Repo.__noizu_repo__(__CALLER__, options, block)
  end


end
