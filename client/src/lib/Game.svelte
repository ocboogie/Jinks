<script>
  import { createEventDispatcher } from "svelte";
  import { Input, Button } from "./base";
  import GameField from "./GameField.svelte";
  import { fade } from "svelte/transition";
  import Thinking from "./Thinking.svelte";

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

  let prevGuessesLength = 0;

  $: {
    meGuesses[0];
    otherPlayerGuesses[0];
    console.log(prevGuessesLength, meGuesses.length);
  }

  $: if (
    meGuesses[0] &&
    otherPlayerGuesses[0] &&
    prevGuessesLength < meGuesses.length &&
    !room.game.won
  ) {
    prevGuessesLength = meGuesses.length;

    if (meGuesses[0] !== otherPlayerGuesses[0]) {
      console.log("Is playing");
      gameField.playWrongAnimation();
    }
  }

  const dispatch = createEventDispatcher();

  function submitGuess() {
    guessed = guess;
    dispatch("guess", guess);
    guess = "";
  }

  function playAgain() {
    dispatch("playAgain");
    guess = "";
    guessed = "";
    prevGuessesLength = 0;
  }
</script>

<GameField
  leftName={otherPlayer.name}
  rightName={me.name}
  leftHistory={otherPlayerGuesses}
  rightHistory={meGuesses}
  leftReady={otherPlayerGuessed}
  rightReady={meGuessed}
  win={room.game.won}
  bind:this={gameField}
/>

<form
  class="flex relative flex-col gap-6 justify-center items-center"
  on:submit|preventDefault={room.game.won ? playAgain : submitGuess}
>
  {#if room.game.won && !room.ready.includes(selfId)}
    <input
      class="{Button} absolute"
      in:fade={{
        duration: 500,
        delay: gameField?.winAnimationDuration.reduce(
          (partialSum, a) => partialSum + a,
          0,
        ),
      }}
      type="submit"
      value="Play Again"
    />
  {/if}
  {#if room.game.won && room.ready.includes(selfId)}
    <Thinking class="absolute" />
  {/if}

  <input
    class:invisible={meGuessed || room.game.won}
    bind:value={guess}
    type="text"
    placeholder="Guess"
    class={Input}
  />

  <input
    class:invisible={meGuessed || room.game.won}
    type="submit"
    class={Button}
    value="Guess"
  />
</form>
