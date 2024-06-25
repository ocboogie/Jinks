<script>
  import { createEventDispatcher } from "svelte";
  import Thinking from "./Thinking.svelte";

  export let selfId;
  export let room;

  let guess = "";
  let guessed = "";

  $: me = room.players.find((player) => player.id === selfId);
  $: otherPlayer = room.players.find((player) => player.id !== selfId);

  $: meReady = room.ready.includes(me.id);
  $: otherPlayerReady = room.ready.includes(otherPlayer.id);

  $: meGuesses = room.game?.guesses.map((guesses) => guesses[me.id]);
  $: otherPlayerGuesses = room.game?.guesses.map(
    (guesses) => guesses[otherPlayer.id],
  );

  $: meGuessed = room.game?.ready.includes(me.id);
  $: otherPlayerGuessed = room.game?.ready.includes(otherPlayer.id);

  const shownHistory = 3;

  const dispatch = createEventDispatcher();

  function submitGuess() {
    guessed = guess;
    dispatch("guess", guess);
    guess = "";
  }
</script>

<div class="flex gap-40 justify-between">
  <div class="flex">
    <div class="py-6 px-3 border-r">{otherPlayer.name}</div>
    <div
      class="flex relative flex-col justify-center items-start ml-3 max-h-52"
    >
      {#if room.game}
        {#each otherPlayerGuesses.slice(0, shownHistory) as guess, i}
          <div
            class="absolute mb-6 whitespace-nowrap"
            class:text-lg={i == 1}
            class:text-xl={i == 0}
            style={`opacity: ${1 / (i + 2)}; transform: translateY(${
              -(i + 1) * 2
            }rem)`}
          >
            {guess}
          </div>
        {/each}
      {/if}
      {#if (room.game && !room.game.ready.includes(otherPlayer.id)) || (!room.game && !otherPlayerReady)}
        <Thinking />
      {:else if (room.game && otherPlayerGuessed) || (!room.game && otherPlayerReady)}
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="currentColor"
          class="mr-2 text-green-500 size-8"
        >
          <path
            fill-rule="evenodd"
            d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm13.36-1.814a.75.75 0 1 0-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 0 0-1.06 1.06l2.25 2.25a.75.75 0 0 0 1.14-.094l3.75-5.25Z"
            clip-rule="evenodd"
          />
        </svg>
      {:else}
        <div class="text-2xl whitespace-nowrap">
          {otherPlayerGuesses[otherPlayerGuesses.length - 1]}
        </div>
      {/if}
    </div>
  </div>
  <div class="flex">
    <div class="flex relative flex-col justify-center items-end mr-3 max-h-52">
      {#if room.game}
        {#each meGuesses.slice(0, shownHistory) as guess, i}
          <div
            class="absolute mb-6 whitespace-nowrap"
            class:text-lg={i == 1}
            class:text-xl={i == 0}
            style={`opacity: ${1 / (i + 2)}; transform: translateY(${
              -(i + 1) * 2
            }rem)`}
          >
            {guess}
          </div>
        {/each}
      {/if}
      {#if (room.game && !room.game.ready.includes(me.id)) || (!room.game && !meReady)}
        <Thinking />
      {:else if !room.game && meReady}
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="currentColor"
          class="mr-2 text-green-500 size-8"
        >
          <path
            fill-rule="evenodd"
            d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm13.36-1.814a.75.75 0 1 0-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 0 0-1.06 1.06l2.25 2.25a.75.75 0 0 0 1.14-.094l3.75-5.25Z"
            clip-rule="evenodd"
          />
        </svg>
      {:else}
        <div class="text-2xl whitespace-nowrap">
          {#if meGuessed}
            {guessed}
          {:else}
            {meGuesses[meGuesses.length - 1]}
          {/if}
        </div>
      {/if}
    </div>
    <div class="py-6 px-3 border-l">{me.name}</div>
  </div>
</div>

<form
  class="flex flex-col gap-6 justify-center items-center"
  class:invisible={room.game && meGuessed}
  on:submit|preventDefault={room.game ? submitGuess : () => dispatch("ready")}
>
  {#if room.game}
    <input
      bind:value={guess}
      type="text"
      placeholder="Guess"
      class="block p-2 w-48 text-lg text-center border-b border-gray-300 outline-none"
    />
  {/if}

  <input
    type="submit"
    class="block py-3 px-6 text-lg font-light tracking-wide text-black rounded-md shadow-lg cursor-pointer drop-shadow-lg"
    value={room.game ? "Guess" : "Ready"}
  />
</form>
