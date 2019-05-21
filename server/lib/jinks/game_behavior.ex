defmodule Jinks.GameBehavior do
  alias Jinks.Player
  alias Jinks.Game.State, as: GameState

  @callback init(%GameState{}) :: {%GameState{}, term()}

  @type handle_event_return ::
          {:keep_behavior, %GameState{}} | {:change_behavior, module(), %GameState{}}

  @callback handle_event({:player_left, %Player{}}, %GameState{}) :: handle_event_return
  @callback handle_event({:player_join, %Player{}}, %GameState{}) :: handle_event_return

  @optional_callbacks handle_event: 2
end
