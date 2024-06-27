<script>
  import { Socket } from "phoenix";
  import { onMount } from "svelte";
  import url from "./lib/url";
  import Home from "./lib/Home.svelte";
  import Lobby from "./lib/Lobby.svelte";
  import Game from "./lib/Game.svelte";
  import WaitingForPlayers from "./lib/WaitingForPlayers.svelte";
  import Toast, { toast } from "./lib/Toast.svelte";

  $: roomId = $url.hash.slice(1) || null;
  let socket;
  let channel;
  let selfId = 1;
  let room = null;
  let closureReason;

  $: if (!roomId) {
    room = null;
  }

  onMount(() => {
    socket = new Socket("ws://localhost:4000/socket", { timeout: 3000 });

    socket.connect();
  });

  async function matchMake(name) {
    const res = await fetch("/api");
    const roomId = await res.json();

    joinRoom(roomId, name);
  }

  function roomJoined(id, playerId) {
    selfId = playerId;
    roomId = id;

    window.history.pushState({}, "", `#${id}`);

    console.log("Joined room", id);
  }

  function joinRoom(roomId, name) {
    console.log("join room");
    channel = socket.channel(`room:${roomId}`, { name });

    channel.on("room_update", (updatedRoom) => {
      room = updatedRoom;
      console.log("room_update", room);
    });

    channel.on("room_closed", ({ reason }) => {
      if (reason === "player_left") {
        closureReason = "Player left";
        toast("Player left");
        channel.leave();
      }
    });

    channel.onClose((reason) => {
      window.history.replaceState({}, "", "/");

      if (reason !== "leave") {
        toast("Room closed");
      }
    });

    channel
      .join()
      .receive("ok", ({ id: selfId }) => roomJoined(roomId, selfId))
      .receive("error", ({ reason }) => {
        if (reason === "not_found") {
          toast("Room not found");
          channel.leave();
        }
      })
      .receive("timeout", () => {
        window.history.replaceState({}, "", "/");
        toast("Connection timed out");
      });
  }

  function leave() {
    channel.leave();

    window.history.replaceState({}, "", "/");
    room = null;
  }

  function ready() {
    channel.push("ready");
  }

  function guess(event) {
    channel.push("guess", event.detail);
  }
</script>

<Toast />

<main class="flex flex-col gap-6 justify-center items-center w-full h-screen">
  {#if !room}
    <Home
      on:matchMake={({ detail }) => matchMake(detail.name)}
      on:joinRoom={({ detail }) => joinRoom(detail.roomId, detail.name)}
    />
  {:else if room.players.length === 1}
    <WaitingForPlayers on:cancel={leave} />
  {:else if !room.game}
    <Lobby {selfId} {room} on:ready={ready} />
  {:else}
    <Game {selfId} {room} on:guess={guess} />
  {/if}
</main>
