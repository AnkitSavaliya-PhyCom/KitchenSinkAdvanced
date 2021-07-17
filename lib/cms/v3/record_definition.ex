defmodule Noizu.CMS.RecordDefinition do

  defmacro __using__(options \\ []) do
    options = Macro.expand(options, __ENV__)
    cms_provider = options[:cms_provider] || Noizu.CMS.V3.Meta.RecordDefinition
    quote do
      use Noizu.DomainObject, unquote(options)
      @before_compile unquote(cms_provider)
    end
  end

  #--------------------------------------------
  # cms_article_entity
  #--------------------------------------------
  defmacro cms_article_entity(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    cms_provider = options[:cms_provider] || Noizu.CMS.V3.Meta.RecordDefinition.ArticleEntity
    modified_block = quote do
                       unquote(block)
                       @before_compile unquote(cms_provider)
                     end
    Noizu.ElixirScaffolding.V3.Meta.DomainObject.Entity.__noizu_entity__(__CALLER__, options, modified_block)
  end

  #--------------------------------------------
  # cms_article_repo
  #--------------------------------------------
  defmacro cms_article_repo(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    cms_provider = options[:cms_provider] || Noizu.CMS.V3.Meta.RecordDefinition.ArticleRepo
    modified_block = quote do
                       unquote(block)
                       @before_compile unquote(cms_provider)
                     end
    Noizu.ElixirScaffolding.V3.Meta.DomainObject.Repo.__noizu_repo__(__CALLER__, options, modified_block)
  end

end
