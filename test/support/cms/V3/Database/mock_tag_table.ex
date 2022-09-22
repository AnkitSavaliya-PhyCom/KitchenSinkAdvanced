defmodule Noizu.Support.V3.CMS.Database.Article.Tag.MockTable do
  @moduledoc false
  require Noizu.V3.Testing.Mnesia.TableMocker
  Noizu.V3.Testing.Mnesia.TableMocker.customize() do
    @table Noizu.V3.CMS.Database.Article.Tag.Table
  end
end
