defmodule JinksWeb.RoomChannel do
  alias Jinks.Room
  alias Jinks.RoomManager
  alias Jinks.Player
  use JinksWeb, :channel

  @impl true
  def join("room:" <> room_id, %{"name" => name}, socket) do
    case RoomManager.get_room(room_id) do
      nil ->
        {:error, %{reason: "room_not_found"}}

      room_pid ->
        player = %Player{name: name, pid: socket.channel_pid, id: socket.assigns.id}

        ref = Process.monitor(room_pid)

        Room.player_join(room_pid, player)

        {:ok, room_id,
         socket
         |> assign(:room_pid, room_pid)
         |> assign(:room_ref, ref)}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _object, _reason}, socket) do
    if ref == socket.assigns.room_ref do
      {:stop, :normal, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_cast({:game_started, word}, socket) do
    push(socket, "new_message", %{"word" => word})
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
