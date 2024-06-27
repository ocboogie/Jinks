defmodule JinksWeb.RoomChannel do
  alias Jinks.Room
  alias Jinks.RoomManager
  alias Jinks.Player
  use JinksWeb, :channel

  @impl true
  def join("room:" <> room_id, %{"name" => name}, socket) do
    case RoomManager.get_room(room_id) do
      nil ->
        {:error, %{reason: "not_found"}}

      room_pid ->
        player = %Player{name: name, pid: socket.channel_pid, id: socket.assigns.id}

        case Room.player_join(room_pid, player) do
          :ok ->
            ref = Process.monitor(room_pid)

            {:ok, player,
             socket
             |> assign(:room_pid, room_pid)
             |> assign(:room_ref, ref)}

          {:error, reason} ->
            {:error, %{reason: reason}}
        end
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
  def handle_cast({:room_update, state}, socket) do
    push(socket, "room_update", state)
    {:noreply, socket}
  end

  @impl true
  def handle_cast({:room_closure, reason}, socket) do
    push(socket, "room_closed", %{"reason" => reason})

    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("ready", _payload, socket) do
    Room.player_ready(socket.assigns.room_pid, socket.assigns.id)
    {:noreply, socket}
  end

  @impl true
  def handle_in("guess", word, socket) do
    Room.player_guessed(socket.assigns.room_pid, socket.assigns.id, word)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
