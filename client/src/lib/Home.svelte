<script>
  import url from "./url";
  import { createEventDispatcher } from "svelte";

  $: roomId = $url.hash.slice(1) || null;
  let name = "";

  const dispatch = createEventDispatcher();
</script>

<h1 class="text-5xl font-light text-zinc-800">Jinks</h1>
<form
  class="flex flex-col gap-6 justify-center items-center"
  on:submit|preventDefault={roomId
    ? () => dispatch("joinRoom", { roomId, name })
    : () => dispatch("matchMake", { name })}
>
  <input
    bind:value={name}
    type="text"
    placeholder="Name"
    class="block p-2 w-48 text-lg text-center border-b border-gray-300 outline-none"
  />

  <input
    type="submit"
    class="block py-3 px-6 text-lg font-light tracking-wide text-black rounded-md shadow-lg cursor-pointer drop-shadow-lg"
    value={roomId ? "Join" : "Find"}
  />
</form>
