defmodule Noizu.Support.V3.CMS.Database.Article.Version.Revision.MockTable do
  @moduledoc false
  require Noizu.V3.Testing.Mnesia.TableMocker
  Noizu.V3.Testing.Mnesia.TableMocker.customize() do
    @table Noizu.V3.CMS.Database.Article.Version.Revision.Table
  end
end
