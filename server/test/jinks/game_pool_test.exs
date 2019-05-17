defmodule Jinks.GamePoolTest do
  use ExUnit.Case
  alias Jinks.GamePool
  doctest Jinks

  setup do
    start_supervised!(GamePool)
    :ok
  end

  test "starts games" do
    assert {:ok, pid} = GamePool.start_game()
    assert is_pid(pid)
  end
end
