defmodule Jinks.GameTest do
  use ExUnit.Case
  alias Jinks.Game
  alias Jinks.Player
  doctest Jinks

  setup do
    pid = start_supervised!({Game, %Game.State{manager_pid: self()}})

    %{game_pid: pid}
  end

  test "Broadcast players leaving", %{game_pid: game_pid} = _context do
    player1_pid = self()
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    player1 = Player.new("1", player1_pid)
    player2 = Player.new("2", player2_pid)

    Game.player_join(game_pid, player1)
    Game.player_join(game_pid, player2)

    Process.exit(player2_pid, :kill)

    assert_receive {:"$gen_cast", {:player_left, player2}}
  end

  test "Games should stop when last player leaves", %{game_pid: game_pid} = _context do
    player_pid = spawn(fn -> Process.sleep(:infinity) end)

    Game.player_join(game_pid, Player.new("1", player_pid))

    ref = Process.monitor(game_pid)

    Process.exit(player_pid, :kill)

    assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
  end

  test "Report looking for players and game being full to manager pid",
       %{game_pid: game_pid} = _context do
    player1_pid = spawn(fn -> Process.sleep(:infinity) end)
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    player1 = Player.new("1", player1_pid)
    player2 = Player.new("2", player2_pid)

    Game.player_join(game_pid, player1)
    Game.player_join(game_pid, player2)

    Process.exit(player2_pid, :kill)

    assert_receive {:"$gen_cast", {:open_game, game_pid}}
    assert_receive {:"$gen_cast", {:close_game, game_pid}}
    assert_receive {:"$gen_cast", {:open_game, game_pid}}
  end

  test "Broadcast game starting", %{game_pid: game_pid} = _context do
    player1 = Player.new("1", self())
    player2 = Player.new("1", spawn(fn -> Process.sleep(:infinity) end))

    Game.player_join(game_pid, player1)
    Game.player_join(game_pid, player2)

    assert_receive {:"$gen_cast", {:game_started, _starting_word}}
  end

  test "broadcast when a player chooses a word", %{game_pid: game_pid} = _context do
    player1_pid = self()
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    player1 = Player.new("1", player1_pid)
    player2 = Player.new("2", player2_pid)

    Game.player_join(game_pid, player1)
    Game.player_join(game_pid, player2)

    Game.player_chose_word(game_pid, player2.id, "foo")

    assert_receive {:"$gen_cast", {:player_chose_word, player2_id, "foo"}}
  end
end
