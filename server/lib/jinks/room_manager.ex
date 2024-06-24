defmodule Jinks.RoomManager do
  use GenServer
  alias Jinks.RoomPool

  defmodule State do
    defstruct rooms: %{}
  end

  def start_link(_init_state) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  def find_available_room() do
    GenServer.call(__MODULE__, :find_available_room)
  end

  def create_room() do
    GenServer.call(__MODULE__, :create_room)
  end

  def get_room(room_id) do
    GenServer.call(__MODULE__, {:get_room, room_id})
  end

  def matchmake() do
    find_available_room() || create_room()
  end

  defp update_room(state, room_id, fun) do
    if Map.has_key?(state.rooms, room_id) do
      %{state | rooms: Map.update!(state.rooms, room_id, fun)}
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
    {:reply,
     case Enum.find(state.rooms, fn {_room_id, room} -> !room.full && !room.private end) do
       nil -> nil
       {room_id, room} -> {room_id, room.pid}
     end, state}
  end

  @impl true
  def handle_call(:create_room, _from, state) do
    {room_id, {:ok, room_pid}} = RoomPool.start_room(self())

    ref = Process.monitor(room_pid)

    rooms = Map.put(state.rooms, room_id, %{ref: ref, pid: room_pid, private: false})

    {:reply, {room_id, room_pid}, %{state | rooms: rooms}}
  end

  @impl true
  def handle_call({:get_room, room_id}, _from, state) do
    {
      :reply,
      case Map.get(state.rooms, room_id) do
        nil -> nil
        room -> room.pid
      end,
      state
    }
  end

  @impl true
  def handle_cast({room_id, :room_full}, state) do
    state = update_room(state, room_id, fn room -> Map.put(room, :full, true) end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({room_id, :looking_for_players}, state) do
    state = update_room(state, room_id, fn room -> Map.put(room, :full, false) end)

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
