defmodule Jinks.GameManagerTest do
  use ExUnit.Case
  alias Jinks.GameManager
  alias Jinks.GamePool
  alias Jinks.Game
  alias Jinks.Player
  doctest Jinks

  setup do
    start_supervised!({GameManager, %GameManager.State{}})
    start_supervised!(GamePool)
    :ok
  end

  test "Creates games" do
    assert is_pid(GameManager.create_game())
  end

  test "Finds available games" do
    closed_game_pid = GameManager.create_game()

    player1_pid = spawn(fn -> Process.sleep(:infinity) end)
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    Game.player_join(closed_game_pid, Player.new("1", player1_pid))
    Game.player_join(closed_game_pid, Player.new("2", player1_pid))

    open_game_pid = GameManager.create_game()

    assert open_game_pid == GameManager.find_available_game()
  end

  test "Matchmakes available games, if none create one" do
    game_pid = GameManager.matchmake()

    assert is_pid(game_pid)

    player1_pid = spawn(fn -> Process.sleep(:infinity) end)
    player2_pid = spawn(fn -> Process.sleep(:infinity) end)

    Game.player_join(game_pid, Player.new("1", player1_pid))

    assert GameManager.matchmake() == game_pid

    Game.player_join(game_pid, Player.new("2", player2_pid))

    assert GameManager.matchmake() != game_pid
  end

  test "Games with no players should not be found" do
    game_pid = GameManager.create_game()

    player_pid = spawn(fn -> Process.sleep(:infinity) end)

    Game.player_join(game_pid, Player.new("1", player_pid))

    Process.exit(player_pid, :kill)

    ref = Process.monitor(game_pid)

    # Wait for game to exit
    receive do
      {:DOWN, ^ref, _, _, _} ->
        assert GameManager.find_available_game() == nil
    end
  end
end
