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

  setup_all do
    :fuse.install(@fuse, {{:standard, 1, 1000}, {:reset, 10_000}})
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
    assert DefusedTestOnly.__info__(:functions) == [foo: 2]
  end

  test "except is respected" do
    assert DefusedTestExcept.__info__(:functions) == [bar: 0]
  end
end
