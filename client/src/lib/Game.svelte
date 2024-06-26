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

<!-- <div class="flex justify-between w-full max-w-xl"> -->
<!--   <PlayerSide -->
<!--     name={otherPlayer.name} -->
<!--     guesses={otherPlayerGuesses} -->
<!--     bind:this={otherPlayerSide} -->
<!--   > -->
<!--     {#if otherPlayerGuessed} -->
<!--       <svg -->
<!--         xmlns="http://www.w3.org/2000/svg" -->
<!--         viewBox="0 0 24 24" -->
<!--         fill="currentColor" -->
<!--         class="my-3 text-green-500 size-8" -->
<!--       > -->
<!--         <path -->
<!--           fill-rule="evenodd" -->
<!--           d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm13.36-1.814a.75.75 0 1 0-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 0 0-1.06 1.06l2.25 2.25a.75.75 0 0 0 1.14-.094l3.75-5.25Z" -->
<!--           clip-rule="evenodd" -->
<!--         /> -->
<!--       </svg> -->
<!--     {:else if !wrongAnimation} -->
<!--       <div class="my-6"> -->
<!--         <Thinking /> -->
<!--       </div> -->
<!--     {/if} -->
<!--   </PlayerSide> -->
<!--   {#if wrongAnimation} -->
<!--     <svg -->
<!--       xmlns="http://www.w3.org/2000/svg" -->
<!--       fill="none" -->
<!--       viewBox="0 0 24 24" -->
<!--       stroke-width="2" -->
<!--       stroke="currentColor" -->
<!--       class="self-center text-red-500 size-10" -->
<!--       in:fly={{ y: -100, duration: wrongAnimationDuration / 2 }} -->
<!--       out:fly={{ y: 100, duration: wrongAnimationDuration / 2 }} -->
<!--     > -->
<!--       <path -->
<!--         stroke-linecap="round" -->
<!--         stroke-linejoin="round" -->
<!--         d="M6 18 18 6M6 6l12 12" -->
<!--       /> -->
<!--     </svg> -->
<!--   {/if} -->
<!---->
<!--   <PlayerSide name={me.name} guesses={meGuesses} right bind:this={meSide}> -->
<!--     {#if meGuessed} -->
<!--       <svg -->
<!--         xmlns="http://www.w3.org/2000/svg" -->
<!--         viewBox="0 0 24 24" -->
<!--         fill="currentColor" -->
<!--         class="my-3 text-green-500 size-8" -->
<!--       > -->
<!--         <path -->
<!--           fill-rule="evenodd" -->
<!--           d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm13.36-1.814a.75.75 0 1 0-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 0 0-1.06 1.06l2.25 2.25a.75.75 0 0 0 1.14-.094l3.75-5.25Z" -->
<!--           clip-rule="evenodd" -->
<!--         /> -->
<!--       </svg> -->
<!--     {:else if !wrongAnimation} -->
<!--       <div class="my-6"> -->
<!--         <Thinking /> -->
<!--       </div> -->
<!--     {/if} -->
<!--   </PlayerSide> -->
<!-- </div> -->
<!---->
<form
  class="flex flex-col gap-6 justify-center items-center"
  class:invisible={meGuessed}
  on:submit|preventDefault={submitGuess}
>
  <input bind:value={guess} type="text" placeholder="Guess" class={Input} />

  <input type="submit" class={Button} value="Guess" />
</form>
