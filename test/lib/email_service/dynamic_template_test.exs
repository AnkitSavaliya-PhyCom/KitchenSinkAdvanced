#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2020 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.EmailService.DynamicTemplateTest do
  use ExUnit.Case, async: false
  require Logger
  alias  Noizu.EmailService.Email.Binding.Dynamic, as: Binding
  alias Binding.Error
  alias Binding.Section
  alias Binding.Selector

  @context Noizu.ElixirCore.CallingContext.admin()

  @template """
  {{!bind required.variable.hint}}
  {{! regular comment }}
  {{!-- comment with nested tokens {{#if !condition}} --}}
  {{#if selection}}
    {{apple}}
    {{#each apple.details}}
      {{this.width}}
    {{/each}}

    {{!bind required.only_if_selection.hint}}
    {{#with nested}}
       {{this.stuff | ignore}}
       {{#with this.stuff.user_name as | myguy | }}
          {{myguy.first_name | output_pipe}}
          {{myguy.via_alias}}
       {{/with}}
    {{/with}}
  {{/if}}

  {{ nested.stuff.user_name.last_name }}
  {{#with nested.stuff.user_name as | myguy | }}
     {{myguy.first_name | output_pipe}}
  {{/with}}

  {{#unless selection}}
      {{oh.my}}
  {{else}}
    {{oh.goodness}}
  {{/unless}}

  """

  @tag :email
  @tag :dynamic_template
  test "Current Selector (root)" do
    selector = fixture(:default)
               |> Binding.current_selector()
    assert selector == %Selector{selector: [:root]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (root): this" do
    {selector_or_error, state} = fixture(:default)
                                 |> Binding.extract_selector("this")
    assert selector_or_error == :error
    assert Kernel.match?(%Error{error: {:extract_clause, :this, :invalid}}, state.last_error)
  end


  @tag :email
  @tag :dynamic_template
  test "Extract Selector (root): this.dolly" do
    {selector_or_error, state} = fixture(:default)
                                 |> Binding.extract_selector("this.dolly")
    assert selector_or_error == :error
    assert Kernel.match?(%Error{error: {:extract_clause, :this, :invalid}}, state.last_error)
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (root): ." do
    {selector_or_error, state} = fixture(:default)
                                 |> Binding.extract_selector(".")
    assert selector_or_error == :error
    assert Kernel.match?(%Error{error: {:extract_clause, :this, :invalid}}, state.last_error)
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (root): ../" do
    {selector_or_error, state} = fixture(:default)
                                 |> Binding.extract_selector("../")
    assert selector_or_error == :error
    assert Kernel.match?(%Error{error: {:select_parent, :already_root}}, state.last_error)
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (root): ../../" do
    {selector_or_error, state} = fixture(:default)
                                 |> Binding.extract_selector("../../")
    assert selector_or_error == :error
    assert Kernel.match?(%Error{error: {:select_parent, :already_root}}, state.last_error)
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (root): hello.dolly" do
    {selector_or_error, _state} = fixture(:default)
                                 |> Binding.extract_selector("!bind hello.dolly")
    assert selector_or_error == %Selector{selector: [:root, {:select, "hello"}, {:key, "dolly"}]}
  end


  @tag :email
  @tag :dynamic_template
  test "Extract Selector (root): hello.dolly[@index]" do
    {selector_or_error, _state} = fixture(:default)
                                 |> Binding.extract_selector("!bind hello.dolly[@index]")
    assert selector_or_error == %Selector{selector: [:root, {:select, "hello"}, {:key, "dolly"}, {:at, "@index"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Current Selector (foo.biz)" do
    selector = fixture(:foo_biz)
               |> Binding.current_selector()
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz): this" do
    {selector_or_error, _state} = fixture(:foo_biz)
                                 |> Binding.extract_selector("this")
    assert selector_or_error == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz): this.dolly" do
    {selector_or_error, _state} = fixture(:foo_biz)
                                 |> Binding.extract_selector("this.dolly")
    assert selector_or_error == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz): ." do
    {selector_or_error, _state} = fixture(:foo_biz)
                                 |> Binding.extract_selector(".")
    assert selector_or_error == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz): ../" do
    {selector_or_error, _state} = fixture(:foo_biz)
                                 |> Binding.extract_selector("../")
    assert selector_or_error == %Selector{selector: [:root, {:select, "foo"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz): ../../" do
    {selector_or_error, state} = fixture(:foo_biz)
                                 |> Binding.extract_selector("../../")
    assert selector_or_error == :error
    assert Kernel.match?(%Error{error: {:select_parent, :already_top}}, state.last_error)
  end


  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz.bop): ../../" do
    {selector_or_error, _state} = fixture(:foo_biz_bop)
                                 |> Binding.extract_selector("../../")
    assert selector_or_error == %Selector{selector: [:root, {:select, "foo"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz.bop): ../dolly" do
    {selector_or_error, _state} = fixture(:foo_biz_bop)
                                 |> Binding.extract_selector("../dolly")
    assert selector_or_error == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz.bop): ../dolly | pipe" do
    {selector_or_error, _state} = fixture(:foo_biz_bop)
                                 |> Binding.extract_selector("../dolly | pipe")
    assert selector_or_error == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz): hello.dolly" do
    {selector_or_error, _state} = fixture(:foo_biz)
                                 |> Binding.extract_selector("!bind hello.dolly")
    assert selector_or_error == %Selector{selector: [:root, {:select, "hello"}, {:key, "dolly"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "Extract Selector (foo.biz): hello.dolly[@index]" do
    {selector_or_error, _state} = fixture(:foo_biz)
                                 |> Binding.extract_selector("!bind hello.dolly[@index]")
    assert selector_or_error == %Selector{selector: [:root, {:select, "hello"}, {:key, "dolly"}, {:at, "@index"}]}
  end


  @tag :email
  @tag :dynamic_template
  test "With Section: hello.dolly" do
    state = fixture(:foo_biz)
    {:cont, state} =  Binding.extract_token({"#with hello.dolly", state}, %{})
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "hello"}, {:key, "dolly"}]}
    [h,t|_] = state.section_stack
    assert h.section == :with
    assert h.clause == %Selector{selector: [:root, {:select, "hello"}, {:key, "dolly"}]}
  end

  @tag :email
  @tag :dynamic_template
  test "With Section: hello.dolly as | sheep | " do
    state = fixture(:foo_biz)
    {:cont, state} = Binding.extract_token({"#with hello.dolly as | sheep | ", state}, %{})
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}]}

    [h,t|_] = state.section_stack
    assert h.section == :with
    assert h.clause == %Selector{selector: [:root, {:select, "hello"}, {:key, "dolly"}]}
    assert h.match["sheep"] == %Selector{selector: [:root, {:select, "hello"}, {:key, "dolly"}]}
    assert t.bind == []
  end

  @tag :email
  @tag :dynamic_template
  test "With Section (foo.biz): this.dolly " do
    state = fixture(:foo_biz)
    {:cont, state} = Binding.extract_token({"#with this.dolly", state}, %{})
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    [h,t|_] = state.section_stack
    assert h.section == :with
    assert h.clause == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    assert t.bind == []

  end

  @tag :email
  @tag :dynamic_template
  test "With Section (foo.biz): this.dolly as | sheep | " do
    state = fixture(:foo_biz)
    {:cont, state} = Binding.extract_token({"#with this.dolly as | sheep | ", state}, %{})
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}]}
    [h,t|_] = state.section_stack
    assert h.section == :with
    assert h.clause == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    assert t.bind == []
    assert h.match["sheep"] == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
  end


  @tag :email
  @tag :dynamic_template
  test "If Section (foo.biz): this.dolly " do
    state = fixture(:foo_biz)
    {:cont, state} = Binding.extract_token({"#if this.dolly", state}, %{})
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}]}

    [h,t|_] = state.section_stack
    assert h.section == :if
    assert h.clause == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    assert t.bind == []
  end


  @tag :email
  @tag :dynamic_template
  test "Section Nesting" do
    state = fixture(:foo_biz)
    {_, state} = Binding.extract_token({"#if this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.dolly", state}, %{})


    # Confirm expected state after with
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    [h,t|_] = state.section_stack
    assert h.section == :with
    assert h.clause == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    assert t.bind == []
    #----

    {_, state} = Binding.extract_token({"#with this.henry as | bob | ", state}, %{})

    # Confirm expected state after nested with.
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    [h,t|_] = state.section_stack
    assert h.section == :with
    assert h.clause == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}, {:key, "henry"}]}
    assert h.match["bob"] == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}, {:key, "henry"}]}
    assert t.bind == []
    #----

    {_, state} = Binding.extract_token({"/with", state}, %{})

    # Confirm expected state after returning to first with
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    [h,t|_] = state.section_stack
    assert h.section == :with
    assert h.clause == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    assert t.bind == []
    #----

    {_, state} = Binding.extract_token({"/with", state}, %{})

    # Confirm expected state after returning to first if
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}]}
    [h,t|_] = state.section_stack
    assert h.section == :if
    assert h.clause == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}]}
    assert t.bind == []
    #----

    {_, state} = Binding.extract_token({"/if", state}, %{})

    # Confirm expected state after returning to root (not selector is still set for this because of fixture construction)
    selector = Binding.current_selector(state)
    assert selector == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}]}
    [h|_] = state.section_stack
    assert h.section == :root
    #----

    assert state.outcome == :ok
  end


  @tag :email
  @tag :dynamic_template
  test "Section Nesting| Unsupported tag - correct close" do
    state = fixture(:foo_biz)
    {_, state} = Binding.extract_token({"#if this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.henry as | bob | ", state}, %{})

    {_, state} = Binding.extract_token({"#apple bob.douglas as | bob | ", state}, %{})

    [h,t|_] = state.section_stack

    assert h.section == {:unsupported, "apple"}
    assert h.clause == %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "dolly"}, {:key, "henry"}, {:key, "douglas"}]} # , as: "bob"

    {_, state} = Binding.extract_token({"/apple", state}, %{})

    {_, state} = Binding.extract_token({"/with", state}, %{})
    {_, state} = Binding.extract_token({"/with", state}, %{})
    {_, state} = Binding.extract_token({"/if", state}, %{})


    assert state.outcome == :ok
  end


  @tag :email
  @tag :dynamic_template
  test "Section Nesting| Unsupported tag - no clause - correct close" do
    state = fixture(:foo_biz)
    {_, state} = Binding.extract_token({"#if this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.henry as | bob | ", state}, %{})

    {_, state} = Binding.extract_token({"#apple", state}, %{})
    [h,t|_] = state.section_stack
    assert h.section == {:unsupported, "apple"}
    assert h.clause == nil
    {_, state} = Binding.extract_token({"/apple", state}, %{})

    {_, state} = Binding.extract_token({"/with", state}, %{})
    {_, state} = Binding.extract_token({"/with", state}, %{})
    {_, state} = Binding.extract_token({"/if", state}, %{})

    assert state.outcome == :ok
  end



  @tag :email
  @tag :dynamic_template
  test "Section Nesting| Unsupported tag - skipped close" do
    state = fixture(:foo_biz)
    {_, state} = Binding.extract_token({"#if this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.henry as | bob | ", state}, %{})

    {_, state} = Binding.extract_token({"#apple", state}, %{})

    {_, state} = Binding.extract_token({"/with", state}, %{})
    {_, state} = Binding.extract_token({"/with", state}, %{})
    {_, state} = Binding.extract_token({"/if", state}, %{})

    assert state.outcome == :ok
  end


  @tag :email
  @tag :dynamic_template
  test "Section Nesting| Unsupported tag - invalid close" do
    state = fixture(:foo_biz)
    {_, state} = Binding.extract_token({"#if this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.henry as | bob | ", state}, %{})

    {_, state} = Binding.extract_token({"#apple", state}, %{})

    {:halt, state} = Binding.extract_token({"/if", state}, %{})
    state.outcome == :error
  end


  @tag :email
  @tag :dynamic_template
  test "Section Nesting| invalid close" do
    state = fixture(:foo_biz)
    {_, state} = Binding.extract_token({"#if this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.dolly", state}, %{})
    {_, state} = Binding.extract_token({"#with this.henry as | bob | ", state}, %{})
    {:halt, state} = Binding.extract_token({"/if", state}, %{})
    state.outcome == :error
  end




  @tag :email
  @tag :dynamic_template
  test "Extract Default Binding" do
    sut = Binding.extract(@template)
    assert sut.outcome == :ok
    assert sut.last_error == nil

    [h|_] = sut.section_stack

    assert length(h.bind) == 3
    assert Enum.at(h.bind, 0).selector == [:root, {:select, "nested"}, {:key, "stuff"}, {:key, "user_name"}, {:key, "last_name"}]
    assert Enum.at(h.bind, 1).selector == [:root, {:select, "required"}, {:key, "variable"}, {:key, "hint"}]
    assert Enum.at(h.bind, 2).selector == [:root, {:select, "nested"}, {:key, "stuff"}, {:key, "user_name"}, {:key, "first_name"}]


    [i|_] = h.children
    i = i.then_clause
    assert Enum.at(i.bind, 0).selector == [:root, {:select, "required"}, {:key, "only_if_selection"}, {:key, "hint"}]
    assert length(sut.section_stack) == 1
    assert length(h.children) == 2
  end

  @tag :email
  @tag :dynamic_template
  test "Prepare Effective Bindings" do
    sut = Binding.extract(@template)
    assert sut.outcome == :ok
    assert sut.last_error == nil

    # define variable selector
    state = %Noizu.RuleEngine.State.InlineStateManager{}
    options = %{variable_extractor: &__MODULE__.variable_extractor/4}
    {response, state} = Noizu.RuleEngine.ScriptProtocol.execute!(sut, state, @context, options)

    alias_test = Enum.filter(response.bind, fn(v) -> v.selector ==  [:root, {:select, "nested"}, {:key, "stuff"}, {:key, "user_name"}, {:key, "via_alias"}] end)
    assert length(alias_test) == 1

  end

  def variable_extractor(selector, state, context, options) do
    {[%{wip: true}, %{wip: false}], state}
  end

  def fixture(fixture, options \\ %{})
  def fixture(:default, _options) do
    %Noizu.EmailService.Email.Binding.Dynamic{}
  end
  def fixture(:foo_biz, _options) do
    %Noizu.EmailService.Email.Binding.Dynamic{
      section_stack: [%Section{current_selector: %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}]}}]
    }
  end
  def fixture(:foo_biz_bop, _options) do
    %Noizu.EmailService.Email.Binding.Dynamic{
      section_stack: [%Section{current_selector: %Selector{selector: [:root, {:select, "foo"}, {:key, "biz"}, {:key, "bop"}]}}]
    }
  end

end