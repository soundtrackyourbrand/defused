defmodule Defused do
  @moduledoc """
  Provides a `defused/3` macro similar to `Kernel#def/2` but that wraps all
  calls to the provided function body in a call to the specified fuse that
  will check and blow the fuse as needed.
  """

  @doc """
  ## Examples

      use Defused
      defused :fuse_name, test(arg) do
        case :rand.uniform() < 0.5 do
          true -> {:ok, arg}
          _ -> {:error, :boom}
        end
      end
  """

  defmacro __using__(_env) do
    quote do
      import unquote(__MODULE__), only: [defused: 3]

      # Otherwise dialyzer complains about some functions
      # never matching :ok -> :ok
      # TODO: remove once not needed anymore.
      @dialyzer :no_match
    end
  end

  defmacro defused(fuse, call, do: block) do
    quote do
      def unquote(call) do
        case :fuse.ask(unquote(fuse), :sync) do
          :ok -> case unquote(block) do
                   :ok -> :ok
                   {:ok, _} = res -> res
                   err ->
                     :fuse.melt(unquote(fuse))
                     err
                 end
          :blown -> {:error, :unavailable}
        end
      end
    end
  end
end
