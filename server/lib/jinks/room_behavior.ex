defmodule Jinks.RoomStage do
  alias Jinks.Player
  alias Jinks.Room.State, as: RoomState

  @callback init(RoomState.t()) :: {RoomState.t(), term()}

  @callback identifier() :: String.t()

  @type handle_event_return ::
          {:keep_stage, RoomState.t()}
          | {:change_stage, module(), RoomState.t()}
          | {:stop, RoomState.t()}

  @callback handle_event({:player_left, Player.t()}, RoomState.t()) :: handle_event_return
  @callback handle_event({:player_join, Player.t()}, RoomState.t()) :: handle_event_return
  @callback handle_event({:player_chose_word, integer, String.t()}, RoomState.t()) ::
              handle_event_return

  @optional_callbacks handle_event: 2
end
