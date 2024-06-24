defmodule Jinks.RoomStage.Lobby do
  alias Jinks.Room
  alias Jinks.RoomStage
  @behaviour RoomStage

  defstruct([])

  @impl RoomStage
  def init(state) do
    {Room.looking_for_players(state), %__MODULE__{}}
  end

  @impl RoomStage
  def identifier() do
    "lobby"
  end

  @impl RoomStage
  def handle_event({:player_join, _player}, state) do
    if length(state.players) >= 2 do
      {:change_stage, Jinks.RoomStage.Play, state}
    else
      # Room.broadcast_to_players(state, state)
      #
      {:keep_stage, state}
    end
  end
end
