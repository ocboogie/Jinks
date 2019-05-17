defmodule Jinks.GameManager do
  use GenServer
  alias Jinks.GamePool

  defmodule State do
    defstruct games: %{}
  end

  def start_link(init_state \\ %State{}) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end

  def find_available_game() do
    GenServer.call(__MODULE__, :find_available_game)
  end

  def create_game() do
    GenServer.call(__MODULE__, :create_game)
  end

  def matchmake() do
    find_available_game() || create_game()
  end

  defp update_game(state, game_pid, fun) do
    if Map.has_key?(state.games, game_pid) do
      %{state | games: Map.update!(state.games, game_pid, fun)}
    else
      state
    end
  end

  @impl true
  def init(init_state) do
    {:ok, init_state}
  end

  @impl true
  def handle_call(:find_available_game, _from, state) do
    pid =
      Map.values(state.games)
      |> Enum.find_value(fn game -> game.open && !game.private && game.pid end)

    # FIXME: Return game
    {:reply, pid, state}
  end

  @impl true
  def handle_call(:create_game, _from, state) do
    {:ok, game_pid} = GamePool.start_game(self())

    ref = Process.monitor(game_pid)

    games = Map.put(state.games, game_pid, %{ref: ref, pid: game_pid, private: false})

    {:reply, game_pid, %{state | games: games}}
  end

  @impl true
  def handle_cast({:open_game, game_pid}, state) do
    state = update_game(state, game_pid, fn game -> Map.put(game, :open, true) end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:close_game, game_pid}, state) do
    state = update_game(state, game_pid, fn game -> Map.put(game, :open, false) end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _object, _reason}, state) do
    games =
      Enum.reject(state.games, fn {_, game} -> game.ref == ref end)
      |> Map.new()

    {:noreply, %{state | games: games}}
  end
end
