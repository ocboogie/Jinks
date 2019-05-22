defmodule Jinks.RoomManager do
  use GenServer
  alias Jinks.RoomPool

  defmodule State do
    defstruct rooms: %{}
  end

  def start_link(init_state \\ %State{}) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end

  def find_available_room() do
    GenServer.call(__MODULE__, :find_available_room)
  end

  def create_room() do
    GenServer.call(__MODULE__, :create_room)
  end

  def matchmake() do
    find_available_room() || create_room()
  end

  defp update_room(state, room_pid, fun) do
    if Map.has_key?(state.rooms, room_pid) do
      %{state | rooms: Map.update!(state.rooms, room_pid, fun)}
    else
      state
    end
  end

  @impl true
  def init(init_state) do
    {:ok, init_state}
  end

  @impl true
  def handle_call(:find_available_room, _from, state) do
    pid =
      Map.values(state.rooms)
      |> Enum.find_value(fn room -> room.open && !room.private && room.pid end)

    # FIXME: Return room
    {:reply, pid, state}
  end

  @impl true
  def handle_call(:create_room, _from, state) do
    {:ok, room_pid} = RoomPool.start_room(self())

    ref = Process.monitor(room_pid)

    rooms = Map.put(state.rooms, room_pid, %{ref: ref, pid: room_pid, private: false})

    {:reply, room_pid, %{state | rooms: rooms}}
  end

  @impl true
  def handle_cast({:open_room, room_pid}, state) do
    state = update_room(state, room_pid, fn room -> Map.put(room, :open, true) end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:close_room, room_pid}, state) do
    state = update_room(state, room_pid, fn room -> Map.put(room, :open, false) end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _object, _reason}, state) do
    rooms =
      Enum.reject(state.rooms, fn {_, room} -> room.ref == ref end)
      |> Map.new()

    {:noreply, %{state | rooms: rooms}}
  end
end
