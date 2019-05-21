defmodule Jinks.Player do
  @enforce_keys [:name, :id]

  defstruct [:name, :id, :pid]

  def new(name, pid \\ nil) do
    %__MODULE__{name: name, pid: pid, id: :erlang.unique_integer()}
  end
end
