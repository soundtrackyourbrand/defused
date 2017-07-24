defmodule DefusedTest do
  use ExUnit.Case
  doctest Defused

  use Defused

  @fuse :test_fuse

  defused @fuse, func() do
    :ok
  end

  :ok = :fuse.install(@fuse, {{:standard, 10, 50}, {:reset, 10_000}})

  test "executes body if fuse is not blown" do
    :ok = :fuse.circuit_enable(@fuse)
    assert func() == :ok
  end
  test "return unavailable error if fuse is blown" do
    :ok = :fuse.circuit_disable(@fuse)
    assert func() == {:error, :unavailable}
  end
end
