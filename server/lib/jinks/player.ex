defmodule Jinks.Player do
  @derive {Jason.Encoder, only: [:name, :id]}

  defstruct name: nil, pid: nil, id: nil

  def new(id, name, pid \\ nil) do
    %__MODULE__{name: name, pid: pid, id: id}
  end
end
