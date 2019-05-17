defmodule Jinks.Game do
  use GenServer

  defmodule State do
    defstruct players: [],
              game_state: :needsPlayers,
              manager_pid: nil,
              looking_for_players: nil,
              game_state: nil
  end

  def start_link(init_state \\ %State{}) do
    GenServer.start_link(__MODULE__, init_state)
  end

  def player_join(pid, player) do
    GenServer.call(pid, {:player_join, player})
  end

  def broadcast_to_players(message, state) do
    Enum.each(state.players, fn player ->
      GenServer.cast(player.pid, message)
    end)
  end

  # TODO: Come up with a better name
  def close_game(state) do
    report_to_manager({:close_game, self()}, state)

    %{state | looking_for_players: false}
  end

  def open_game(state) do
    report_to_manager({:open_game, self()}, state)

    %{state | looking_for_players: true}
  end

  defp report_to_manager(message, state) do
    if Map.has_key?(state, :manager_pid) do
      GenServer.cast(state.manager_pid, message)
    end
  end

  defp report_event(state, event) do
    case state.game_state.__struct__.handle_event(event, state) do
      {:change_state, new_game_state, new_state} ->
        change_game_state(new_state, new_game_state)

      {:no_change, state} ->
        state
    end
  end

  defp change_game_state(state, game_state) do
    {state, game_state} = game_state.init(state)

    new_state = %{state | game_state: game_state}

    new_state
  end

  @impl true
  def init(init_state) do
    state = change_game_state(init_state, Jinks.GameState.Lobby)

    {:ok, state}
  end

  @impl true
  def handle_call({:player_join, player}, _from, state) do
    ref = Process.monitor(player.pid)

    state =
      %{state | players: [Map.put(player, :ref, ref) | state.players]}
      |> report_event({:player_join, player})

    {:reply, nil, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _object, _reason}, state) do
    player = Enum.find(state.players, &(&1.ref == ref))

    broadcast_to_players({:player_left, player}, state)

    state = %{state | players: List.delete(state.players, player)}

    if length(state.players) <= 0 do
      {:stop, :normal, state}
    else
      {:noreply, report_event(state, {:player_left, player})}
    end
  end
end
