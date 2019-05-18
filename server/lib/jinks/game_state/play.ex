defmodule Jinks.GameState.Play do
  alias Jinks.Game
  alias Jinks.GameState
  @behaviour GameState

  defmodule PlayerInfo do
    defstruct score: 0, word: nil
  end

  defstruct player_info: %{}, current_word: "Hello"

  @impl GameState
  def init(state) do
    player_info =
      Enum.map(state.players, fn player -> {player.pid, %PlayerInfo{}} end)
      |> Map.new()

    play_state = %__MODULE__{player_info: player_info}

    Game.broadcast_to_players({:game_started, play_state.current_word}, state)

    {Game.close_game(state), play_state}
  end

  @impl GameState
  def handle_event({:player_left, _player}, state) do
    if length(state.players) < 2 do
      {:change_state, Jinks.GameState.Lobby, state}
    else
      {:no_change, state}
    end
  end
end
