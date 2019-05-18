defmodule Jinks.Player do
  @enforce_keys [:name]

  defstruct [:name, :pid]
end
