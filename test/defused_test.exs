defmodule DefusedTest do
  use ExUnit.Case
  doctest Defused

  @fuse :test_fuse

  defmodule DefusedTest do
    @fuse :test_fuse
    use Defused

    defused @fuse, func() do
      :ok
    end
  end

  defmodule DefusedTestError do
    @fuse :test_fuse
    use Defused

    defused @fuse, func() do
      :ok
    end

    def blown_error(fuse, call) do
      {:error, fuse, call}
    end
  end

  setup_all do
    :fuse.install(@fuse, {{:standard, 10, 50}, {:reset, 10_000}})
  end

  test "executes body if fuse is not blown" do
    :ok = :fuse.circuit_enable(@fuse)
    assert DefusedTest.func() == :ok
  end
  test "return unavailable error if fuse is blown" do
    :ok = :fuse.circuit_disable(@fuse)
    assert DefusedTest.func() == {:error, :unavailable}
  end
  test "blown error is overridable" do
    :ok = :fuse.circuit_disable(@fuse)
    assert DefusedTestError.func() == {:error, @fuse, [func: 0]}
  end
end
