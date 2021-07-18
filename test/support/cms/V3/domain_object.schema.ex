defmodule Noizu.Support.V3.CMS.DomainObject.Schema do
  require Noizu.DomainObject
  alias Noizu.ElixirScaffolding.V3.Implementation.DomainObject.Scaffolding.DefaultScaffoldingSchemaProvider.Default, as: Provider

  Noizu.DomainObject.noizu_scaffolding_schema(app: :kitchen_sink, base_prefix: Noizu.V3.CMS, database_prefix: Noizu.V3.CMS.Ecto) do
    @cache_keys %{
      mnesia_tables: :"__nzss__#{@app}__mnesia",
    }

    def nmid_keys(), do: __noizu_info__(:nmid_indexes)
    def __noizu_info__(:mnesia_tables = property) do
      Provider.cached_filter(@cache_keys[property], :kitchen_sink, Noizu.V3.CMS.Database, MapSet.new([:table, :entity_table, :enum_table]))
    end
  end


  @doc """
    Note,must stay in sync with UniversalIdentifierResolution.Source.Entity
  """
  def __nmid_index_list__() do
    %{
      Elixir.Noizu.V3.CMS.Database.Article.Table => 1,
      Elixir.Noizu.V3.CMS.Database.Article.Index.Table => 2,
      Elixir.Noizu.V3.CMS.Database.Article.Tag.Table => 3,
      Elixir.Noizu.V3.CMS.Database.Article.Version.Table => 4,
      Elixir.Noizu.V3.CMS.Database.Article.Version.Revision.Table => 5,
      Elixir.Noizu.V3.CMS.Database.Article.Active.Version.Table => 6,
      Elixir.Noizu.V3.CMS.Database.Article.VersionSequencer.Table => 7,
    }
  end
end

#--------------------------------
#
#--------------------------------
defimpl Noizu.ERP, for: BitString do
  def ref(sref), do: Jetzy.DomainObject.Schema.parse_sref(sref)
  def id(sref), do: ref(sref) |> Noizu.ERP.id()
  def sref("ref." <> _ = sref), do: sref
  def sref(_), do: nil
  def entity(sref, options \\ nil), do: Noizu.ERP.entity(ref(sref), options)
  def entity!(sref, options \\ nil), do: Noizu.ERP.entity!(ref(sref), options)
  def record(sref, options \\ nil), do: Noizu.ERP.record(ref(sref), options)
  def record!(sref, options \\ nil), do: Noizu.ERP.record!(ref(sref), options)
end
