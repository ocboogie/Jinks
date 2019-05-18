defmodule Jinks.GameState do
  alias Jinks.Player
  alias Jinks.Game.State, as: GameState

  @callback init(%GameState{}) :: {%GameState{}, term()}

  @type player_left_event :: {:player_left, %Player{}}
  @type player_join_event :: {:player_join, %Player{}}

  @callback handle_event(player_left_event | player_join_event, %GameState{}) ::
              {:no_change, %GameState{}} | {:change_state, module(), %GameState{}}
end
