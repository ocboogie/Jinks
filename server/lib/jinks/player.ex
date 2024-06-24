defmodule Jinks.Player do
  use TypedStruct

  typedstruct do
    field(:name, String.t(), enforce: true)
    field(:id, integer, enforce: true)
    field(:pid, pid)
  end

  def new(id, name, pid \\ nil) do
    %__MODULE__{name: name, pid: pid, id: id}
  end
end
