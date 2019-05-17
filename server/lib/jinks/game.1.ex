# defmodule Jinks.Game do
#   use GenServer
#   alias Jinks.Player

#   defmodule State do
#     defstruct players: [],
#               game_state: :needsPlayers,
#               manager_pid: nil,
#               game_state: %Jinks.GameState.Lobby{}
#   end

#   def start_link(init_state \\ %State{}) do
#     GenServer.start_link(__MODULE__, init_state)
#   end

#   def player_join(pid, player) do
#     GenServer.call(pid, {:player_join, player})
#   end

#   defp player_left(state, player_leaving) do
#     Enum.each(state.players, fn player ->
#       Player.player_left(player.pid, player_leaving)
#     end)
#   end

#   defp enough_players?(state) do
#     length(state.players) >= 2
#   end

#   defp update_game_state(state) do
#     new_game_state =
#       if enough_players?(state) do
#         :ready
#       else
#         :needsPlayers
#       end

#     if new_game_state != state.game_state do
#       Enum.each(state.players, fn player ->
#         Jinks.Player.game_state_change(player.pid, new_game_state)
#       end)

#       if Map.has_key?(state, :manager_pid) do
#         GenServer.cast(state.manager_pid, {:game_state_change, {self(), new_game_state}})
#       end
#     end

#     %{state | game_state: new_game_state}
#   end

#   @impl true
#   def init(init_state) do
#     {:ok, init_state}
#   end

#   @impl true
#   def handle_call({:player_join, player}, _from, state) do
#     ref = Process.monitor(player.pid)

#     state =
#       %{state | players: [Map.put(player, :ref, ref) | state.players]}
#       |> update_game_state

#     {:reply, nil, state}
#   end

#   @impl true
#   def handle_info({:DOWN, ref, :process, _object, _reason}, state) do
#     player_leaving = Enum.find(state.players, &(&1.ref == ref))

#     state = %{state | players: List.delete(state.players, player_leaving)}

#     player_left(state, player_leaving)

#     state = update_game_state(state)

#     {:noreply, state}
#   end
# end
