defmodule Jinks.RoomPoolTest do
  use ExUnit.Case
  alias Jinks.RoomPool
  doctest Jinks

  setup do
    start_supervised!(RoomPool)
    :ok
  end

  test "starts rooms" do
    assert {:ok, pid} = RoomPool.start_room()
    assert is_pid(pid)
  end
end
