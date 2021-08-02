defmodule Noizu.Support.V3.CMS.Database.Article.Tag.MockTable do
  @moduledoc false
  require Noizu.Testing.Mnesia.TableMocker
  Noizu.Testing.Mnesia.TableMocker.customize() do
    @table Noizu.V3.CMS.Database.Article.Tag.Table
  end
end
