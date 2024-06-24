defmodule JinksWeb.RoomController do
  use JinksWeb, :controller
  alias Jinks.RoomManager

  def matchmake(conn, _params) do
    {room_id, _room_pid} = RoomManager.matchmake()

    conn
    |> put_status(:ok)
    |> json(room_id)
  end
end
