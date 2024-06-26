<script>
  import { createEventDispatcher } from "svelte";
  import Thinking from "./Thinking.svelte";
  import { Input, Button } from "./base";
  import PlayerSide from "./PlayerSide.svelte";

  export let selfId;
  export let room;

  let guess = "";
  let guessed = "";

  $: me = room.players.find((player) => player.id === selfId);
  $: otherPlayer = room.players.find((player) => player.id !== selfId);

  $: meReady = room.ready.includes(me.id);
  $: otherPlayerReady = room.ready.includes(otherPlayer.id);

  const dispatch = createEventDispatcher();
</script>

<div class="flex gap-40 justify-between">
  <PlayerSide name={otherPlayer.name}>
    {#if otherPlayerReady}
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="currentColor"
        class="text-green-500 size-8"
      >
        <path
          fill-rule="evenodd"
          d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm13.36-1.814a.75.75 0 1 0-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 0 0-1.06 1.06l2.25 2.25a.75.75 0 0 0 1.14-.094l3.75-5.25Z"
          clip-rule="evenodd"
        />
      </svg>
    {:else}
      <Thinking />
    {/if}
  </PlayerSide>
  <PlayerSide name={me.name} right>
    {#if meReady}
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="currentColor"
        class="text-green-500 size-8"
      >
        <path
          fill-rule="evenodd"
          d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm13.36-1.814a.75.75 0 1 0-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 0 0-1.06 1.06l2.25 2.25a.75.75 0 0 0 1.14-.094l3.75-5.25Z"
          clip-rule="evenodd"
        />
      </svg>
    {:else}
      <Thinking />
    {/if}
  </PlayerSide>
</div>

<form on:submit|preventDefault={() => dispatch("ready")}>
  <input type="submit" class={Button} value="Ready" />
</form>
