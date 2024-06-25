<script>
  import { createEventDispatcher } from "svelte";
  import Thinking from "./Thinking.svelte";

  const dispatch = createEventDispatcher();
</script>

<h1 class="mb-6 text-3xl font-light text-zinc-800">Waiting For Players</h1>

<Thinking />

<form class="mt-3" on:submit|preventDefault={() => dispatch("cancel")}>
  <input
    type="submit"
    class="block py-3 px-6 text-lg font-light tracking-wide text-black rounded-md shadow-lg cursor-pointer drop-shadow-lg"
    value="Cancel"
  />
</form>
