defmodule Jinks.GameBehavior.Lobby do
  alias Jinks.Game
  alias Jinks.GameBehavior
  @behaviour GameBehavior

  defstruct([])

  @impl GameBehavior
  def init(state) do
    {Game.open_game(state), %__MODULE__{}}
  end

  @impl GameBehavior
  def handle_event({:player_join, _player}, state) do
    if length(state.players) >= 2 do
      {:change_behavior, Jinks.GameBehavior.Play, state}
    else
      {:keep_behavior, state}
    end
  end
end
