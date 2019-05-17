# defmodule Jinks.GameManager do
#   use GenServer
#   alias Jinks.GamePool

#   def start_link(init_state \\ []) do
#     GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
#   end

#   def find_available_game() do
#     GenServer.call(__MODULE__, :find_available_game)
#   end

#   def create_game() do
#     GenServer.call(__MODULE__, :create_game)
#   end

#   def matchmake() do
#     find_available_game() || create_game()
#   end

#   @impl true
#   def init(init_state) do
#     {:ok, init_state}
#   end

#   @impl true
#   def handle_call(:find_available_game, _from, state) do
#     {pid, _} =
#       Enum.find(state, fn {_, game_state} ->
#         game_state == :needsPlayers
#       end)

#     {:reply, pid, state}
#   end

#   @impl true
#   def handle_call(:create_game, _from, state) do
#     {:ok, game_pid} = GamePool.start_game(self())

#     state = [game_pid | state]

#     {:reply, game_pid, state}
#   end

#   @impl true
#   def handle_cast({:looking_for_players, game_pid}, state) do
#     state = Map.put(state, game_pid, new_game_state)
#     {:noreply, state}
#   end
# end
