defmodule Jinks.RoomTest do
  use ExUnit.Case
  alias Jinks.Room
  alias Jinks.Player
  doctest Jinks

  setup do
    pid = start_supervised!({Room, %Room.State{manager_pid: self()}})

    %{room_pid: pid}
  end

  test "Rooms should stop when a player leaves", %{room_pid: room_pid} = _context do
    player1_pid = spawn(fn -> Process.sleep(:infinity) end)
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    Room.player_join(room_pid, Player.new("1", player1_pid))
    Room.player_join(room_pid, Player.new("2", player2_pid))

    ref = Process.monitor(room_pid)

    Process.exit(player2_pid, :kill)

    assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
  end

  test "Report looking for players and room being full to manager pid",
       %{room_pid: room_pid} = _context do
    player1_pid = spawn(fn -> Process.sleep(:infinity) end)
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    player1 = Player.new("1", player1_pid)
    player2 = Player.new("2", player2_pid)

    Room.player_join(room_pid, player1)
    Room.player_join(room_pid, player2)

    Process.exit(player2_pid, :kill)

    assert_receive {:"$gen_cast", {:open_room, room_pid}}
    assert_receive {:"$gen_cast", {:close_room, room_pid}}
    assert_receive {:"$gen_cast", {:open_room, room_pid}}
  end

  test "Broadcast room starting", %{room_pid: room_pid} = _context do
    player1 = Player.new("1", self())
    player2 = Player.new("1", spawn(fn -> Process.sleep(:infinity) end))

    Room.player_join(room_pid, player1)
    Room.player_join(room_pid, player2)

    assert_receive {:"$gen_cast", {:room_started, _starting_word}}
  end

  test "broadcast when a player chooses a word", %{room_pid: room_pid} = _context do
    player1_pid = self()
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    player1 = Player.new("1", player1_pid)
    player2 = Player.new("2", player2_pid)

    Room.player_join(room_pid, player1)
    Room.player_join(room_pid, player2)

    Room.player_chose_word(room_pid, player2.id, "foo")

    assert_receive {:"$gen_cast", {:player_chose_word, player2_id, "foo"}}
  end

  test "broadcast if won and new word when all players have chosen their word",
       %{room_pid: room_pid} = _context do
    player1_pid = self()
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    player1 = Player.new("1", player1_pid)
    player2 = Player.new("2", player2_pid)

    player1_id = player1.id
    player2_id = player2.id

    Room.player_join(room_pid, player1)
    Room.player_join(room_pid, player2)

    Room.player_chose_word(room_pid, player1.id, "foo")
    Room.player_chose_word(room_pid, player2.id, "bar")

    assert_receive {:"$gen_cast",
                    {:round_finished,
                     %{
                       players_words: %{^player1_id => "foo", ^player2_id => "bar"},
                       won: false,
                       new_word: new_word
                     }}}
                   when new_word not in ["foo", "bar"] and new_word != nil

    Room.player_chose_word(room_pid, player1.id, "baz")
    Room.player_chose_word(room_pid, player2.id, "baz")

    assert_receive {:"$gen_cast",
                    {:round_finished,
                     %{
                       players_words: %{^player1_id => "baz", ^player2_id => "baz"},
                       won: true,
                       new_word: "baz"
                     }}}
  end
end
