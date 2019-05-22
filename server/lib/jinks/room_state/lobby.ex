defmodule Jinks.RoomBehavior.Lobby do
  alias Jinks.Room
  alias Jinks.RoomBehavior
  @behaviour RoomBehavior

  defstruct([])

  @impl RoomBehavior
  def init(state) do
    {Room.looking_for_players(state), %__MODULE__{}}
  end

  @impl RoomBehavior
  def handle_event({:player_join, _player}, state) do
    if length(state.players) >= 2 do
      {:change_behavior, Jinks.RoomBehavior.Play, state}
    else
      {:keep_behavior, state}
    end
  end
end
