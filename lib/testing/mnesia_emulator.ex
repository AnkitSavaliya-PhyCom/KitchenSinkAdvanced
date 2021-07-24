defmodule Noizu.Testing.MnesiaEmulator do
  use Agent

  @initial_state  %{tables: %{}, event: 0, history: []}
  @blank_table %{records: %{}, history: []}
  @blank_record %{record: nil, history: []}
  #-----------------------------
  # Handle
  #-----------------------------
  defp emulator_handle(nil), do: __MODULE__
  defp emulator_handle(instance), do: {__MODULE__, instance}

  #-----------------------------
  # Start Agent
  #-----------------------------
  def start_link(instance \\ nil), do: Agent.start_link(fn() -> @initial_state end, name: emulator_handle(instance))

  #-----------------------------
  # Internal State Manipulation
  #-----------------------------
  def __emulator__(instance \\ nil), do: Agent.get(emulator_handle(instance), &(&1))
  def __table__(table, instance \\ nil), do: Agent.get(emulator_handle(instance), &(&1.tables[table]))
  def __record__(table, key, instance \\ nil), do: Agent.get(emulator_handle(instance), &(&1.tables[table][key]))
  def __history__(instance \\ nil), do: Agent.get(emulator_handle(instance), &(&1.history))
  def __table_history__(table, instance \\ nil), do: Agent.get(emulator_handle(instance), &(&1.tables[table][:history]))
  def __record_history__(table, key, instance \\ nil), do: Agent.get(emulator_handle(instance), &(&1.tables[table][key][:history]))

  #-----------------------------
  #
  #-----------------------------
  def write(table, key, record, instance \\ nil) do
    Agent.update(emulator_handle(instance), fn(state) ->
      event = state.event + 1
      state
      |> put_in([:event], event)
      |> update_in([:history], &(&1 ++ [{event, {:write, {table, key}}}]))
      |> update_in([:tables, table], &(&1 || @blank_table))
      |> update_in([:tables, table, :records, key], &(&1 || @blank_record))
      |> update_in([:tables, table, :history], &(&1 ++ [{event, {:write, key}}]))
      |> update_in([:tables, table, :records, key, :history], &(&1 ++ [{event, {:write, record}}]))
      |> put_in([:tables, table, :records, key, :record], record)
    end)
    record
  end

  #-----------------------------
  #
  #-----------------------------
  def write_bag(table, key, record, instance \\ nil) do
    Agent.update(emulator_handle(instance), fn(state) ->
      event = state.event + 1
      state
      |> put_in([:event], event)
      |> update_in([:history], &(&1 ++ [{event, {:write, {table, key}}}]))
      |> update_in([:tables, table], &(&1 || @blank_table))
      |> update_in([:tables, table, :records, key], &(&1 || @blank_record))
      |> update_in([:tables, table, :history], &(&1 ++ [{event, {:write, key}}]))
      |> update_in([:tables, table, :records, key, :history], &(&1 ++ [{event, {:write, record}}]))
      |> update_in([:tables, table, :records, key, :record], &(Enum.uniq((&1 || []) ++ [record])))
    end)
    record
  end

  #-----------------------------
  #
  #-----------------------------
  def delete(table, key, instance \\ nil) do
    Agent.update(emulator_handle(instance), fn(state) ->
      event = state.event + 1
      state
      |> put_in([:event], event)
      |> update_in([:history], &(&1 ++ [{event, {:delete, {table, key}}}]))
      |> update_in([:tables, table], &(&1 || @blank_table))
      |> update_in([:tables, table, :records, key], &(&1 || @blank_record))
      |> update_in([:tables, table, :history], &(&1 ++ [{event, {:delete, key}}]))
      |> update_in([:tables, table, :records, key, :history], &(&1 ++ [{event, :delete}]))
      |> put_in([:tables, table, :records, key, :record], nil)
    end)
  end

  #-----------------------------
  #
  #-----------------------------
  def reset(instance \\ nil), do: Agent.update(emulator_handle(instance), fn(_) -> @initial_state end)

  #-----------------------------
  #
  #-----------------------------
  def get(table, key, default, instance \\ nil) do
    Agent.get(emulator_handle(instance), fn(state) ->
      cond do
        state.tables[table][:records][key] -> state.tables[table][:records][key].record
        :else -> default
      end
    end)
  end

  #-----------------------------
  #
  #-----------------------------
  def match(table, pattern, instance \\ nil) do
    values = Agent.get(emulator_handle(instance), fn(state) ->
      (state.tables[table][:records] || [])
      |> Enum.filter(&(partial_compare(&1.record, pattern)))
    end)
    %Amnesia.Table.Select{values: values, coerce: table}
  end

  #-----------------------------
  #
  #-----------------------------
  defp partial_compare(_, :_), do: true
  defp partial_compare(v, p) when is_atom(p) do
    cond do
      v == p -> true
      String.starts_with?(Atom.to_string(p), "$") -> true
      :else -> false
    end
  end
  defp partial_compare(v, p) when is_tuple(p) do
    cond do
      v == p -> true
      !is_tuple(v) -> false
      tuple_size(v) != tuple_size(p) -> false
      :else ->
        vl = Tuple.to_list(v)
        pl = Tuple.to_list(p)
        Enum.reduce(1..tuple_size(v), true, fn(i,a) ->
          a && partial_compare(Enum.at(vl, i), Enum.at(pl, i))
        end)
    end
  end
  defp partial_compare(v, p) when is_list(p) and is_list(v) do
    cond do
      length(v) != length(p) -> false
      v == p -> true
      :else ->
        Enum.reduce(1..length(v), true, fn(i,a) ->
          a && partial_compare(Enum.at(v, i), Enum.at(p, i))
        end)
    end
  end
  defp partial_compare(v, p) when is_list(p) and is_map(v) do
    Enum.reduce(p, true, fn({f,fp},a) ->
      cond do
        !a -> a
        !Map.has_key?(v, f) -> false
        v = partial_compare(Map.get(v, f), fp) -> v
        :else -> false
      end
    end)
  end
  defp partial_compare(v, p) when is_map(p) and is_map(v) do
    Enum.reduce(p, true, fn({f,fp},a) ->
      cond do
        !a -> a
        !Map.has_key?(v, f) -> false
        v = partial_compare(Map.get(v, f), fp) -> v
        :else -> false
      end
    end)
  end
  defp partial_compare(v, p) do
    v == p
  end

  defmacro mock_table(table, options \\ [], [do: block]) do
    table = Macro.expand(table, __ENV__)
    options = Macro.expand(options, __ENV__)
    stubbed = options[:stubbed] || nil
    default_mock_strategy = options[:strategy] || :auto
    quote do
      @default_mock_strategy cond do
        unquote(default_mock_strategy) == :auto -> Module.concat([__MODULE__, "DefaultStrategy"])
        :else -> unquote(default_mock_strategy)
      end

      def default_mock_strategy(), do: @default_mock_strategy

      def strategy(mock_strategy \\ :auto, mock_settings \\ nil) do
        mock_strategy = if mock_strategy == :auto, do: default_mock_strategy(), else: mock_strategy
        [
          read: fn(key) -> mock_strategy.read(mock_settings, key) end,
          read!: fn(key) -> mock_strategy.read!(mock_settings, key) end,
          write: fn(record) -> mock_strategy.write(mock_settings, record) end,
          write!: fn(record) -> mock_strategy.write!(mock_settings, record) end,
          delete: fn(record) -> mock_strategy.delete(mock_settings, record) end,
          delete!: fn(record) -> mock_strategy.delete!(mock_settings, record) end,
          match: fn(selector) -> mock_strategy.match(mock_settings, selector) end,
          match!: fn(selector) -> mock_strategy.match!(mock_settings, selector) end,
        ]
      end

      defoverridable [
        default_mock_strategy: 0,
        strategy: 0,
        strategy: 1,
        strategy: 2
      ]

      defmodule DefaultStrategy do
        def read(mock_settings, key) do
          read!(mock_settings, key)
        end

        def read!(mock_settings, key) do
          default_value = cond do
                            Map.has_key?(mock_settings[:stubbed] || %{}, key) -> mock_settings[:stubbed][key]
                            :else -> unquote(stubbed)[key]
                          end
          Noizu.Testing.MnesiaEmulator.get(unquote(table), key, default_value, mock_settings[:emulator])
        end

        def write(mock_settings, record) do
          write!(mock_settings, record)
        end

        def write!(mock_settings, record) do
          key = get_in(record, [Access.key(List.first(unquote(table).attributes))])
          cond do
            mock_settings[:bag] -> Noizu.Testing.MnesiaEmulator.write_bag(unquote(table), key, record, mock_settings[:emulator])
            :else -> Noizu.Testing.MnesiaEmulator.write(unquote(table), key, record, mock_settings[:emulator])
          end
        end

        def delete(mock_settings, record) do
          delete!(mock_settings, record)
        end

        def delete!(mock_settings, key) do
          Noizu.Testing.MnesiaEmulator.delete(unquote(table), key, mock_settings[:emulator])
        end

        def match(mock_settings, selector) do
          match!(mock_settings, selector)
        end

        def match!(mock_settings, selector) do
          Noizu.Testing.MnesiaEmulator.match(unquote(table), selector, mock_settings[:emulator])
        end

      end
    end
  end

end
