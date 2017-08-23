defmodule Defused.ModuleTest do
  use ExUnit.Case
  @fuse :defused_module_fuse

  defmodule Test do
    def foo(_a, _b) do
      {:ok, :hello}
    end

    def bar do
      {:error, :broken}
    end
  end

  defmodule DefusedTest do
    @fuse :defused_module_fuse
    use Defused.Module, target: Test, fuse: @fuse
  end

  defmodule DefusedTestOnly do
    @fuse :defused_module_fuse
    use Defused.Module, target: Test, fuse: @fuse, only: [foo: 2]
  end

  defmodule DefusedTestExcept do
    @fuse :defused_module_fuse
    use Defused.Module, target: Test, fuse: @fuse, except: [foo: 2]
  end

  defmodule DefusedTestError do
    @fuse :defused_module_fuse
    use Defused.Module, target: Test, fuse: @fuse

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
    assert DefusedTest.bar() == {:error, :broken}
    :ok = :fuse.circuit_disable(@fuse)
    assert DefusedTest.bar() == {:error, :unavailable}
  end

  test "only is respected" do
    assert funcs(DefusedTestOnly) == [foo: 2]
  end

  test "except is respected" do
    assert funcs(DefusedTestExcept) == [bar: 0]
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
