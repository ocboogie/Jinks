defmodule Jinks.GamePool do
  use DynamicSupervisor
  alias Jinks.Game

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_game(manager_pid \\ nil) do
    DynamicSupervisor.start_child(__MODULE__, {Game, %Game.State{manager_pid: manager_pid}})
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
