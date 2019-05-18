defmodule Jinks.Player do
  @enforce_keys [:name, :pid]

  defstruct [:name, :pid]
end
