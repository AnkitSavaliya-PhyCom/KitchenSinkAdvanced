defmodule Noizu.V3.CMS.ArticleType do

  defmacro __using__(options \\ []) do
    options = Macro.expand(options, __ENV__)
    options = update_in(options, [:extension_imp], &(&1 || Noizu.V3.CMS.Meta.ArticleType.Base))
    quote do
      use Noizu.DomainObject, unquote(options)
    end
  end

  #--------------------------------------------
  # article_entity
  #--------------------------------------------
  defmacro article_entity(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    options = update_in(options, [:extension_imp], &(&1 || Noizu.V3.CMS.Meta.ArticleType.Entity))
    Noizu.ElixirScaffolding.V3.Meta.DomainObject.Entity.__noizu_entity__(__CALLER__, options, block)
  end

  #--------------------------------------------
  # article_repo
  #--------------------------------------------
  defmacro article_repo(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    options = update_in(options, [:extension_imp], &(&1 || Noizu.V3.CMS.Meta.ArticleType.Repo))
    Noizu.ElixirScaffolding.V3.Meta.DomainObject.Repo.__noizu_repo__(__CALLER__, options, block)
  end

end
