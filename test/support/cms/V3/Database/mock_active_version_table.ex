defmodule Noizu.Support.V3.CMS.Database.Article.Active.Version.MockTable do
  @moduledoc false
  require Noizu.V3.Testing.Mnesia.TableMocker
  Noizu.V3.Testing.Mnesia.TableMocker.customize() do
    @table Noizu.V3.CMS.Database.Article.Active.Version.Table
  end
end
