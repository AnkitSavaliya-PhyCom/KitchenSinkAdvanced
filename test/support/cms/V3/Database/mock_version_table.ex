defmodule Noizu.Support.V3.CMS.Database.Article.Version.MockTable do
  @moduledoc false
  require Noizu.Testing.Mnesia.TableMocker
  Noizu.Testing.Mnesia.TableMocker.customize() do
    @table Noizu.V3.CMS.Database.Article.Version.Table
  end
end
