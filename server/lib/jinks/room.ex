defmodule Jinks.Room do
  use GenServer

  defmodule State do
    use TypedStruct

    typedstruct do
      field(:players, list(Jink.Player.t()), default: [])
      field(:manager_pid, pid)
      field(:full, boolean())
      field(:behavior_state, term())
    end
  end

  def start_link(init_state \\ %State{}) do
    GenServer.start_link(__MODULE__, init_state)
  end

  def player_join(pid, player) do
    GenServer.call(pid, {:player_join, player})
  end

  def player_chose_word(pid, player_id, word) do
    GenServer.cast(pid, {:player_chose_word, player_id, word})
  end

  def broadcast_to_players(message, state) do
    Enum.each(state.players, fn player ->
      GenServer.cast(player.pid, message)
    end)
  end

  def full(state) do
    report_to_manager({:room_full, self()}, state)

    %{state | full: true}
  end

  def looking_for_players(state) do
    report_to_manager({:looking_for_players, self()}, state)

    %{state | full: false}
  end

  defp report_to_manager(message, state) do
    if Map.has_key?(state, :manager_pid) do
      GenServer.cast(state.manager_pid, message)
    end
  end

  defp report_event(state, event) do
    case state.behavior_state.__struct__.handle_event(event, state) do
      {:change_behavior, new_room_behavior, new_state} ->
        {:ok, change_room_behavior(new_state, new_room_behavior)}

      {:keep_behavior, state} ->
        {:ok, state}

      {:stop, state} ->
        {:stop, state}
    end
  end

  defp change_room_behavior(state, behavior) do
    {state, behavior_state} = behavior.init(state)

    new_state = %{state | behavior_state: behavior_state}

    new_state
  end

  @impl true
  def init(init_state) do
    state = change_room_behavior(init_state, Jinks.RoomBehavior.Lobby)

    {:ok, state}
  end

  @impl true
  def handle_call({:player_join, player}, _from, state) do
    ref = Process.monitor(player.pid)

    player = Map.put(player, :ref, ref)

    state = %{state | players: [player | state.players]}

    case report_event(state, {:player_join, player}) do
      {:ok, state} -> {:reply, player, state}
      {:stop, state} -> {:stop, :normal, state}
    end
  end

  @impl true
  def handle_cast(unknown, state) do
    case report_event(state, unknown) do
      {:ok, state} -> {:noreply, state}
      {:stop, state} -> {:stop, :normal, state}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _object, _reason}, state) do
    player = Enum.find(state.players, &(&1.ref == ref))

    state = %{state | players: List.delete(state.players, player)}

    if length(state.players) <= 0 do
      {:stop, :normal, state}
    else
      case report_event(state, {:player_left, player}) do
        {:ok, state} -> {:reply, player, state}
        {:stop, state} -> {:stop, :normal, state}
      end
    end
  end
end
