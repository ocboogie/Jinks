defmodule Jinks.RoomPool do
  use DynamicSupervisor
  alias Jinks.Room

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_room(manager_pid \\ nil) do
    DynamicSupervisor.start_child(__MODULE__, {Room, %Room.State{manager_pid: manager_pid}})
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
