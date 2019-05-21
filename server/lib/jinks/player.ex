defmodule Jinks.Player do
  use TypedStruct

  typedstruct do
    field(:name, String.t(), enforce: true)
    field(:id, integer, enforce: true)
    field(:pid, pid)
  end

  def new(name, pid \\ nil) do
    %__MODULE__{name: name, pid: pid, id: :erlang.unique_integer()}
  end
end
