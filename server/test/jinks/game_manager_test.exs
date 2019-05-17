defmodule Jinks.GameManagerTest do
  use ExUnit.Case
  alias Jinks.GameManager
  alias Jinks.GamePool
  alias Jinks.Game
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

    Game.player_join(closed_game_pid, %{pid: spawn(fn -> Process.sleep(:infinity) end)})
    Game.player_join(closed_game_pid, %{pid: spawn(fn -> Process.sleep(:infinity) end)})

    open_game_pid = GameManager.create_game()

    assert open_game_pid == GameManager.find_available_game()
  end

  test "Matchmakes available games, if none create one" do
    game_pid = GameManager.matchmake()

    assert is_pid(game_pid)

    Game.player_join(game_pid, %{pid: spawn(fn -> Process.sleep(:infinity) end)})

    assert GameManager.matchmake() == game_pid

    Game.player_join(game_pid, %{pid: spawn(fn -> Process.sleep(:infinity) end)})

    assert GameManager.matchmake() != game_pid
  end

  test "Games with no players should not be found" do
    game_pid = GameManager.create_game()

    player_pid = spawn(fn -> Process.sleep(:infinity) end)

    Game.player_join(game_pid, %{pid: player_pid})

    Process.exit(player_pid, :kill)

    ref = Process.monitor(game_pid)

    # Wait for game to exit
    receive do
      {:DOWN, ^ref, _, _, _} ->
        assert GameManager.find_available_game() == nil
    end
  end
end
