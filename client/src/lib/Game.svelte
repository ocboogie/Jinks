<script>
  import { fly } from "svelte/transition";
  import { createEventDispatcher } from "svelte";
  import Thinking from "./Thinking.svelte";
  import { Input, Button } from "./base";
  import PlayerSide from "./PlayerSide.svelte";
  import GameField from "./GameField.svelte";

  export let selfId;
  export let room;

  let gameField;

  let guess = "";
  let guessed = "";

  $: me = room.players.find((player) => player.id === selfId);
  $: otherPlayer = room.players.find((player) => player.id !== selfId);

  $: meGuesses = room.game?.guesses.map((guesses) => guesses[me.id]);
  $: otherPlayerGuesses = room.game?.guesses.map(
    (guesses) => guesses[otherPlayer.id],
  );

  $: meGuessed = room.game?.ready.includes(me.id);
  $: otherPlayerGuessed = room.game?.ready.includes(otherPlayer.id);

  let prevGuessesLenght = 0;

  $: if (
    meGuesses[0] &&
    otherPlayerGuesses[0] &&
    prevGuessesLenght < meGuesses.length
  ) {
    prevGuessesLenght = meGuesses.length;

    if (meGuesses[0] !== otherPlayerGuesses[0]) {
      gameField.playWrongAnimation();
    } else {
      gameField.playWinAnimation();
    }
  }

  const dispatch = createEventDispatcher();

  function submitGuess() {
    guessed = guess;
    dispatch("guess", guess);
    guess = "";
  }
</script>

<GameField
  leftName={otherPlayer.name}
  rightName={me.name}
  leftHistory={otherPlayerGuesses}
  rightHistory={meGuesses}
  leftReady={otherPlayerGuessed}
  rightReady={meGuessed}
  bind:this={gameField}
/>

<form
  class="flex flex-col gap-6 justify-center items-center"
  class:invisible={meGuessed}
  on:submit|preventDefault={submitGuess}
>
  <input bind:value={guess} type="text" placeholder="Guess" class={Input} />

  <input type="submit" class={Button} value="Guess" />
</form>
