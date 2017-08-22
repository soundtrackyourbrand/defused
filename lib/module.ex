defmodule Defused.Module do
  defmacro __using__(opts) do
    target = Keyword.fetch!(opts, :target)
    fuse = Keyword.fetch!(opts, :fuse)

    quote location: :keep,
          bind_quoted: [
            target: target,
            fuse: fuse
          ] do

      use Defused
      fns = target.__info__(:functions)

      Enum.map(fns, fn {name, arity} ->
        args = case arity do
          0 -> []
          n ->
            1..arity
            |> Enum.map(fn n -> Macro.var("var#{n}" |> String.to_atom, __MODULE__) end)
        end

        defused unquote(fuse), unquote(name)(unquote_splicing(args)) do
          unquote(target).unquote(name)(unquote_splicing(args))
        end
      end)
    end
  end
end
