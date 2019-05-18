defmodule Jinks.GameState.Lobby do
  alias Jinks.Game
  alias Jinks.GameState
  @behaviour GameState

  defstruct([])

  @impl GameState
  def init(state) do
    {Game.open_game(state), %__MODULE__{}}
  end

  @impl GameState
  def handle_event({:player_join, _player}, state) do
    if length(state.players) >= 2 do
      {:change_state, Jinks.GameState.Play, state}
    else
      {:no_change, state}
    end
  end
end
