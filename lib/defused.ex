defmodule Defused do
  @moduledoc """
  Provides a `defused/3` macro similar to `Kernel#def/2` but that wraps all
  calls to the provided function body in a call to the specified fuse that
  will check and blow the fuse as needed.

  ## Examples

      use Defused
      defused :fuse_name, test(arg) do
        case :rand.uniform() < 0.5 do
          true -> {:ok, arg}
          _ -> {:error, :boom}
        end
      end
  """

  @doc false
  defmacro __using__(_env) do
    quote do
      import unquote(__MODULE__), only: [defused: 3]

      # Otherwise dialyzer complains about some functions
      # never matching :ok -> :ok
      # TODO: remove once not needed anymore.
      @dialyzer :no_match

      @doc false
      def blown_error(_fuse, _call) do
        {:error, :unavailable}
      end

      defoverridable [blown_error: 2]
    end
  end

  @doc """
  Runs the provided do block only if the fuse haven't been blown.

  ## Examples
    def func() do
      fused :fuse, do
        :ok
      end
    end
  """
  defmacro fused(fuse, do: block) do
    quote do
      case :fuse.ask(unquote(fuse), :sync) do
        :ok ->
          case unquote(block) do
            :ok -> :ok
            {:ok, _} = res -> res
            err ->
              :fuse.melt(unquote(fuse))
              err
          end
        :blown -> blown_error(unquote(fuse), [__ENV__.function])
      end
    end
  end

  @doc """
  Defines a fused function with the given fuse name, function name
  and body.

  ## Examples

      defmodule Foo do
        defused :fuse, bar, do: :ok
      end

      Foo.bar #=> :ok

  ## Returns

  A defused function must return either `:ok` or `{:ok, _}`, otherwise
  the fuse will melt, and eventually blow.

  When the fuse is blown, the function will return `{:error, :unavailable}`

  """
  defmacro defused(fuse, call, do: block) do
    quote do
      def unquote(call) do
        Defused.fused(unquote(fuse), do: unquote(block))
      end
    end
  end
end
