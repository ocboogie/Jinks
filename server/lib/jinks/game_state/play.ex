defmodule Jinks.GameBehavior.Play do
  alias Jinks.Game
  alias Jinks.GameBehavior
  @behaviour GameBehavior

  defmodule PlayerInfo do
    defstruct score: 0, word: nil
  end

  defstruct player_info: %{}, current_word: "Hello"

  @impl GameBehavior
  def init(state) do
    player_info =
      Enum.map(state.players, fn player -> {player.id, %PlayerInfo{}} end)
      |> Map.new()

    play_state = %__MODULE__{player_info: player_info}

    Game.broadcast_to_players({:game_started, play_state.current_word}, state)

    {Game.close_game(state), play_state}
  end

  @impl GameBehavior
  def handle_event({:player_left, _player}, state) do
    if length(state.players) < 2 do
      {:change_behavior, Jinks.GameBehavior.Lobby, state}
    else
      {:keep_behavior, state}
    end
  end
end
