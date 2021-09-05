defmodule Noizu.V3.CMS.ArticleType.Versioning do

  defmacro __using__(options \\ []) do
    options = Macro.expand(options, __ENV__)
    options = update_in(options, [:extension_implementation], &(&1 || Noizu.V3.CMS.Meta.ArticleType.Versioning.Base))
    quote do
      use Noizu.DomainObject, unquote(options)
    end
  end

  #--------------------------------------------
  # versioning_entity
  #--------------------------------------------
  defmacro versioning_entity(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    options = update_in(options, [:extension_implementation], &(&1 || Noizu.V3.CMS.Meta.ArticleType.Versioning.Entity))
    Noizu.AdvancedScaffolding.Internal.DomainObject.Entity.__noizu_entity__(__CALLER__, options, block)
  end

  #--------------------------------------------
  # versioning_repo
  #--------------------------------------------
  defmacro versioning_repo(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    options = update_in(options, [:extension_implementation], &(&1 || Noizu.V3.CMS.Meta.ArticleType.Versioning.Repo))
    Noizu.AdvancedScaffolding.Internal.DomainObject.Repo.__noizu_repo__(__CALLER__, options, block)
  end



end
