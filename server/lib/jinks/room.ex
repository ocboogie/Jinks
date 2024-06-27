defmodule Jinks.Room do
  require Logger
  use GenServer

  @id_length 16

  defmodule State do
    defimpl Jason.Encoder, for: [MapSet, Range, Stream] do
      def encode(struct, opts) do
        Jason.Encode.list(Enum.to_list(struct), opts)
      end
    end

    defmodule Game do
      defimpl Jason.Encoder, for: Game do
        def encode(game, opts) do
          Jason.Encode.map(
            %{
              guesses: game.guesses,
              ready:  Map.keys(game.current_guesses)
            },
            opts
          )
        end
      end

      defstruct guesses: [], current_guesses: %{}
    end

    @derive {Jason.Encoder, only: [:players, :id, :ready, :game]}
    defstruct players: [], manager_pid: nil, id: nil, ready: %MapSet{}, game: nil
  end

  def generate_id() do
    :crypto.strong_rand_bytes(@id_length) |> Base.url_encode64() |> binary_part(0, @id_length)
  end

  def start_link(init_state \\ %State{id: generate_id()}) do
    Logger.info "Starting room #{init_state.id}"

    GenServer.start_link(__MODULE__, init_state)
  end

  def player_join(pid, player) do
    GenServer.call(pid, {:player_join, player})
  end

  def player_ready(pid, player_id) do
    GenServer.cast(pid, {:player_ready, player_id})
  end

  def player_guessed(pid, player_id, word) do
    GenServer.cast(pid, {:player_guessed, player_id, word})
  end

  def broadcast_update(state) do
    Enum.each(state.players, fn player ->
      GenServer.cast(player.pid, {:room_update, state})
    end)
  end

  def broadcast_closure(state, reason) do
    Enum.each(state.players, fn player ->
      GenServer.cast(player.pid, {:room_closure, reason})
    end)
  end

  def full?(state) do
    length(state.players) >= 2
  end

  defp report_to_manager(message, state) do
    if Map.has_key?(state, :manager_pid) do
      GenServer.cast(state.manager_pid, {state.id, message})
    end
  end

  defp start_game(state) do
    state = %{state | ready: %MapSet{}, game: %State.Game{}}
    broadcast_update(state)

    state
  end

  defp reset(state) do
    report_to_manager(:looking_for_players, state)
    state = %{state | ready: %MapSet{}}
    broadcast_update(state)
    # TODO: Delete game state
  end

  @impl true
  def init(init_state) do
    if !full?(init_state) do
      report_to_manager(:looking_for_players, init_state)
    end

    schedule_timeout()

    {:ok, init_state}
  end

  @impl true
  def handle_call({:player_join, player}, _from, state) do
    if full?(state) do
      {:reply, {:error, :room_full}, state}
    else
      ref = Process.monitor(player.pid)

      player = Map.put(player, :ref, ref)

      state = %{state | players: [player | state.players]}

      if full?(state) do
        report_to_manager(:room_full, state)
      end

      broadcast_update(state)

      {:reply, :ok, state}
    end
  end

  @impl true
  def handle_cast({:player_ready, player_id}, state) do
    ready = MapSet.put(state.ready, player_id)

    if MapSet.size(ready) == length(state.players) do
      {:noreply, start_game(state)}
    else
      state = %{state | ready: ready}

      broadcast_update(state)

      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:player_guessed, player_id, word}, state) do
    state = update_in(state.game.current_guesses, &(Map.put(&1, player_id, word)))

    state = if map_size(state.game.current_guesses) == length(state.players) do
      guesses = [state.game.current_guesses | state.game.guesses]

      %{state | game: %{state.game | guesses: guesses, current_guesses: %{}}}
    else
      state
    end

    broadcast_update(state)

    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _object, _reason}, state) do
    player = Enum.find(state.players, &(&1.ref == ref))

    state = %{state | players: List.delete(state.players, player)}

    IO.puts("Player #{player.id} left room #{state.id}")
    broadcast_closure(state, :player_left)

    {:stop, :normal, state}
  end

  @impl true
  def handle_info(:timeout, state) do
    if length(state.players) == 0 do
      Logger.warning("Room #{state.id} timed out with no players")
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  defp schedule_timeout do
    # 5 seconds
    Process.send_after(self(), :timeout, 5 * 1000)
  end
end
