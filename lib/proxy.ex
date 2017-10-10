defmodule Defused.Proxy do
  defmacro __using__(opts \\ []) do
    mod = Macro.expand(Keyword.fetch!(opts, :target), __CALLER__)
    fuse = Keyword.fetch!(opts, :fuse)
    only = Keyword.get(opts, :only)
    except = Keyword.get(opts, :except)

    fns = :functions |> mod.__info__() |> MapSet.new()

    defuse = cond do
      only ->
        only = MapSet.new(only)
        fns
        |> Enum.filter(fn {name, _} -> MapSet.member?(only, name) end)
      except ->
        except = MapSet.new(except)
        fns
        |> Enum.filter(fn {name, _} -> !MapSet.member?(except, name) end)
      true -> fns
    end

    signatures = Enum.map(defuse, fn {name, arity} ->
      args = Macro.generate_arguments(arity, nil)
      quote do
        defused unquote(fuse), unquote(name)(unquote_splicing(args)) do
          unquote(mod).unquote(name)(unquote_splicing(args))
        end
      end
    end)

    quote do
      use Defused
      unquote_splicing(signatures)
    end
  end
end
