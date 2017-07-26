# Defused

[![Build Status](https://travis-ci.org/soundtrackyourbrand/defused.svg?branch=master)](https://travis-ci.org/soundtrackyourbrand/defused)
[![Inline docs](http://inch-ci.org/github/soundtrackyourbrand/defused.svg)](http://inch-ci.org/github/soundtrackyourbrand/defused)

Provides a `defused/3` macro similar to `Kernel#def/2` but that wraps all calls to the provided function body in a call to the specified fuse that will check and blow the fuse as needed.

# Usage

You first need to install a fuse, see [fuse source](https://github.com/jlouis/fuse)

```elixir
defmodule MyModule do
  use Defused

  defused :fuse_name, test(arg) do
    case :rand.uniform() < 0.5 do
      true -> {:ok, arg}
      _ -> {:error, :boom}
    end
  end
end
```

## Installation

Add `defused` to you dependencies

```elixir
def deps do
  [{:defused, "~> 0.1.0"}]
end
```

