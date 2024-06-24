<script>
  import { Socket } from "phoenix";
  import { onMount } from "svelte";
  import url from "./lib/url";

  let socket;
  let name = "";
  $: roomId = $url.hash;

  onMount(() => {
    socket = new Socket("ws://localhost:4000/socket", { timeout: 3000 });

    socket.connect();
  });

  async function matchMake() {
    const res = await fetch("/api");
    const roomId = await res.json();

    joinRoom(roomId);
  }

  function roomJoined(id) {
    roomId = id;

    window.history.pushState({}, "", `#${id}`);

    console.log("Joined room", id);
  }

  function joinRoom(roomId) {
    const channel = socket.channel(`room:${roomId}`, { name });

    channel.on("new_message", (payload) => {
      console.log(payload);
    });

    channel
      .join()
      .receive("ok", (room_id) => roomJoined(room_id))
      .receive("error", ({ reason }) => console.log("failed join", reason))
      .receive("timeout", () =>
        console.log("Networking issue. Still waiting..."),
      );
  }
</script>

<main class="flex flex-col gap-6 justify-center items-center w-full h-screen">
  <h1 class="text-5xl font-light text-zinc-800">Jinks</h1>
  <form
    class="flex flex-col gap-6 justify-center items-center"
    on:submit|preventDefault={matchMake}
  >
    <input
      bind:value={name}
      type="text"
      placeholder="Name"
      class="block p-2 w-48 text-lg text-center border-b border-gray-300 outline-none"
    />

    <!-- Rounded start button with a big shadow -->
    <input
      type="submit"
      class="block py-3 px-6 text-lg font-light tracking-wide text-black rounded-md shadow-lg cursor-pointer drop-shadow-lg"
      value="Start"
    />
  </form>
</main>
