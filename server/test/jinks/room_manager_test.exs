defmodule Jinks.RoomManagerTest do
  use ExUnit.Case
  alias Jinks.RoomManager
  alias Jinks.RoomPool
  alias Jinks.Room
  alias Jinks.Player
  doctest Jinks

  setup do
    start_supervised!({RoomManager, %RoomManager.State{}})
    start_supervised!(RoomPool)
    :ok
  end

  test "Creates rooms" do
    assert is_pid(RoomManager.create_room())
  end

  test "Finds available rooms" do
    closed_room_pid = RoomManager.create_room()

    player1_pid = spawn(fn -> Process.sleep(:infinity) end)
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    Room.player_join(closed_room_pid, Player.new("1", player1_pid))
    Room.player_join(closed_room_pid, Player.new("2", player1_pid))

    assert RoomManager.find_available_room() == nil

    open_room_pid = RoomManager.create_room()

    assert open_room_pid == RoomManager.find_available_room()
  end

  test "Matchmakes available rooms, if none create one" do
    room_pid = RoomManager.matchmake()

    assert is_pid(room_pid)

    player1_pid = spawn(fn -> Process.sleep(:infinity) end)
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    Room.player_join(room_pid, Player.new("1", player1_pid))

    assert RoomManager.matchmake() == room_pid

    Room.player_join(room_pid, Player.new("2", player2_pid))

    assert RoomManager.matchmake() != room_pid
  end

  test "Rooms with no players should not be found" do
    room_pid = RoomManager.create_room()

    player_pid = spawn(fn -> Process.sleep(:infinity) end)

    Room.player_join(room_pid, Player.new("1", player_pid))

    Process.exit(player_pid, :kill)

    ref = Process.monitor(room_pid)

    # Wait for room to exit
    receive do
      {:DOWN, ^ref, _, _, _} ->
        assert RoomManager.find_available_room() == nil
    end
  end
end
