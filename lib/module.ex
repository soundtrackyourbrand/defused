defmodule Defused.Module do
  defmacro __using__(opts) do
    quote do
      fuse = Keyword.fetch!(unquote(opts), :fuse)

      only = case Keyword.get(unquote(opts), :only, nil) do
        nil -> nil
        x -> MapSet.new(x)
      end

      except = case Keyword.get(unquote(opts), :except, nil) do
        nil -> nil
        x -> MapSet.new(x)
      end

      if only && except do
        throw "Cannot specify both `only` and `except`"
      end

      use Defused
      import Kernel, except: [def: 2]
      import Defused.Module

      @defused_only only
      @defused_except except
    end
  end

  defp meta(call) do
    case call do
      {:when, _, [call | _]} -> meta(call)
      {name, _, args} ->
        arity = case args do
          nil -> 0
          args -> length(args)
        end
        {name, arity}
    end
  end

  defmacro def(call, expr \\ nil) do
    quote do
      {name, arity} = unquote(meta(call))

      cond do
        {name, arity} == {:blown_error, 2} -> Kernel.def(unquote(call), unquote(expr))
        @defused_only != nil ->
          case MapSet.member?(@defused_only, {name, arity}) do
            false -> Kernel.def(unquote(call), unquote(expr))
            true -> defused @fuse, unquote(call), unquote(expr)
          end
        @defused_except != nil ->
          case MapSet.member?(@defused_except, {name, arity}) do
            true -> Kernel.def(unquote(call), unquote(expr))
            false -> defused @fuse, unquote(call), unquote(expr)
          end
        true -> defused @fuse, unquote(call), unquote(expr)
      end
    end
  end
end
