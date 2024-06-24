defmodule Jinks.RoomStage.Play do
  alias Jinks.Room
  alias Jinks.RoomStage
  @behaviour RoomStage

  defmodule PlayerInfo do
    # TODO: Remove score no need
    defstruct score: 0, word: nil
  end

  defstruct player_info: %{}, current_word: "Hello"

  def round_finished(state) do
    players_words =
      Enum.map(state.stage_state.player_info, fn {player_id, %{word: word}} ->
        {player_id, word}
      end)
      |> Map.new()

    won =
      length(
        Enum.uniq_by(
          state.stage_state.player_info,
          fn {_, %{word: word}} -> word end
        )
      ) == 1

    new_word =
      if won do
        List.first(Map.values(state.stage_state.player_info)).word
      else
        Jinks.WordList.pick()
      end

    Room.broadcast_to_players(
      {:round_finished, %{players_words: players_words, won: won, new_word: new_word}},
      state
    )

    reset_players_words(state)
    |> Map.update!(
      :stage_state,
      &Map.put(&1, :word, new_word)
    )
  end

  defp reset_players_words(state) do
    update_in(
      state.stage_state.player_info,
      &Enum.map(&1, fn {_, player_info} ->
        Map.delete(player_info, :word)
      end)
    )
  end

  @impl RoomStage
  def identifier() do
    "play"
  end

  @impl RoomStage
  def init(state) do
    player_info =
      Enum.map(state.players, fn player -> {player.id, %PlayerInfo{}} end)
      |> Map.new()

    play_state = %__MODULE__{player_info: player_info}

    Room.broadcast_to_players({:game_started, play_state.current_word}, state)

    {Room.full(state), play_state}
  end

  @impl RoomStage
  def handle_event({:player_left, _player}, state) do
    if length(state.players) < 2 do
      {:stop, state}
    else
      {:keep_stage, state}
    end
  end

  @impl RoomStage
  def handle_event({:player_chose_word, player_id, word}, state) do
    state =
      update_in(state.stage_state.player_info[player_id], fn player_info ->
        %{player_info | word: word}
      end)

    if Enum.all?(state.stage_state.player_info, fn {_, player_info} ->
         player_info.word != nil
       end) do
      round_finished(state)
    else
      # TODO: Change the message from a 3 tuple to a 2 tuple with a map
      Room.broadcast_to_players({:player_chose_word, player_id, word}, state)
      state
    end

    {:keep_stage, state}
  end
end
