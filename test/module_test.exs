defmodule Defused.ModuleTest do
  use ExUnit.Case
  @fuse :defused_module_fuse

  defmodule DefusedTest do
    @fuse :defused_module_fuse
    use Defused.Module, fuse: @fuse

    def foo(_a, _b) do
      {:ok, :hello}
    end

    def bar do
      {:error, :broken}
    end
  end

  defmodule DefusedTestError do
    @fuse :defused_module_fuse
    use Defused.Module, fuse: @fuse

    def foo(_a, _b) do
      {:ok, :hello}
    end

    def bar do
      {:error, :broken}
    end

    def blown_error(fuse, call) do
      {:error, fuse, call}
    end
  end

  setup_all do
    :fuse.install(@fuse, {{:standard, 10, 1000}, {:reset, 10_000}})
  end

  setup do
    :ok = :fuse.circuit_enable(@fuse)
  end

  test "ok functions" do
    :ok = :fuse.circuit_enable(@fuse)
    assert DefusedTest.foo(1, 2) == {:ok, :hello}
  end

  test "erroring functions" do
    :ok = :fuse.circuit_enable(@fuse)
    assert DefusedTest.bar() == {:error, :broken}
    :ok = :fuse.circuit_disable(@fuse)
    assert DefusedTest.bar() == {:error, :unavailable}
  end

  defmodule DefusedTestOnly do
    @fuse :defused_module_fuse
    use Defused.Module, fuse: @fuse, only: [foo: 2]

    def foo(_a, _b) do
      {:ok, :hello}
    end

    def bar do
      :ok
    end
  end

  test "only gets the correct arity" do
    assert funcs(DefusedTestOnly) == [bar: 0, foo: 2]
  end

  test "only is respected" do
    :ok = :fuse.circuit_disable(@fuse)
    assert DefusedTestOnly.bar == :ok
    assert DefusedTestOnly.foo(1, 2) == {:error, :unavailable}
  end

  defmodule DefusedTestExcept do
    @fuse :defused_module_fuse

    use Defused.Module, fuse: @fuse, except: [foo: 2]

    def foo(a, _b) when a < 2 do
      {:ok, :hello}
    end

    def foo(a, _b) when a < 2 and a > 0 do
      {:ok, :hello}
    end

    def foo(_a, _b) do
      {:ok, :hello}
    end

    def bar do
      {:error, :broken}
    end
  end

  test "except gets the correct arity" do
    assert funcs(DefusedTestExcept) == [bar: 0, foo: 2]
  end

  test "except is respected" do
    :ok = :fuse.circuit_disable(@fuse)
    assert DefusedTestExcept.foo(1,2) == {:ok, :hello}
    assert DefusedTestExcept.bar() == {:error, :unavailable}
  end

  test "can override blown error" do
    assert DefusedTestError.bar() == {:error, :broken}
    :ok = :fuse.circuit_disable(@fuse)
    assert DefusedTestError.bar() == {:error, @fuse, [bar: 0]}
  end

  def funcs(target) do
    target.__info__(:functions) |> Enum.reject(fn {f, a} ->
      f == :blown_error && a == 2
    end)
  end
end
