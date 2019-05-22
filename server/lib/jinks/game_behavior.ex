defmodule Jinks.GameBehavior do
  alias Jinks.Player
  alias Jinks.Game.State, as: GameState

  @callback init(GameState.t()) :: {GameState.t(), term()}

  @type handle_event_return ::
          {:keep_behavior, GameState.t()}
          | {:change_behavior, module(), GameState.t()}
          | {:stop, GameState.t()}

  @callback handle_event({:player_left, Player.t()}, GameState.t()) :: handle_event_return
  @callback handle_event({:player_join, Player.t()}, GameState.t()) :: handle_event_return
  @callback handle_event({:player_chose_word, integer, String.t()}, GameState.t()) ::
              handle_event_return

  @optional_callbacks handle_event: 2
end
