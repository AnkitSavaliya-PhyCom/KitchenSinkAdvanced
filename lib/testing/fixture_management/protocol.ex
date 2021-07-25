defprotocol Noizu.Testing.FixtureManagement.Protocol do
  def release(fixture, options)
  def reserve(fixture, until, options)
  def tag(fixture, tag, value, options)
  def flag(fixture, message, options)
  def history(fixture, options)
end

defimpl Noizu.Testing.FixtureManagement.Protocol, for: Any do
  def release(_fixture, _options), do: :pending
  def reserve(_fixture, _until, _options), do: :pending
  def tag(_fixture, _tag, _value, _options), do: :pending
  def flag(_fixture, _message, _options), do: :pending
  def history(_fixture, _options), do: :pending

  defmacro __deriving__(module, _struct, _options) do
    module = Macro.expand(module, __ENV__)
    # options = Macro.expand(options, __ENV__)
    quote do
      defimpl Noizu.Testing.FixtureManagement.Protocol, for: unquote(module) do
        def release(_fixture, _options), do: :pending
        def reserve(_fixture, _until, _options), do: :pending
        def tag(_fixture, _tag, _value, _options), do: :pending
        def flag(_fixture, _message, _options), do: :pending
        def history(_fixture, _options), do: :pending
      end
    end
  end
end



defimpl Noizu.Testing.FixtureManagement.Protocol, for: Tuple do

  def release(fixture, options) do
    cond do
      fixture = Noizu.ERP.entity!(fixture) -> Noizu.Testing.FixtureManagement.Protocol.release(fixture, options)
      :else -> raise "Fixture Resolution Failed"
    end
  end

  def reserve(fixture, until, options) do
    cond do
      fixture = Noizu.ERP.entity!(fixture) -> Noizu.Testing.FixtureManagement.Protocol.reserve(fixture, until, options)
      :else -> raise "Fixture Resolution Failed"
    end
  end

  def tag(fixture, attribute, value, options) do
    cond do
      fixture = Noizu.ERP.entity!(fixture) -> Noizu.Testing.FixtureManagement.Protocol.tag(fixture, attribute, value, options)
      :else -> raise "Fixture Resolution Failed"
    end
  end

  def flag(fixture, message, options)do
    cond do
      fixture = Noizu.ERP.entity!(fixture) -> Noizu.Testing.FixtureManagement.Protocol.flag(fixture, message, options)
      :else -> raise "Fixture Resolution Failed"
    end
  end

  def history(fixture, options)do
    cond do
      fixture = Noizu.ERP.entity!(fixture) -> Noizu.Testing.FixtureManagement.Protocol.history(fixture, options)
      :else -> raise "Fixture Resolution Failed"
    end
  end
end
