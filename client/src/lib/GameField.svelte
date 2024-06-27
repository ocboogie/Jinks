<script>
  import { fly } from "svelte/transition";
  import PlayerSide from "./PlayerSide.svelte";
  import Thinking from "./Thinking.svelte";
  import { tick } from "svelte";

  const wrongAnimationDuration = 1500;
  export const winAnimationDuration = [500, 600, 500];

  export let leftName;
  export let rightName;
  export let leftHistory;
  export let rightHistory;
  export let leftReady;
  export let rightReady;
  export let win;

  let wrongAnimation = false;

  let winTarget;

  let leftSide;
  let rightSide;

  let leftLastGuess;
  let rightLastGuess;

  export function playWrongAnimation() {
    wrongAnimation = true;

    tick().then(() => {
      leftSide.scrollToBottom();
      rightSide.scrollToBottom();
    });

    setTimeout(() => {
      wrongAnimation = false;

      tick().then(() => {
        leftSide.scrollToBottom();
        rightSide.scrollToBottom();
      });
    }, wrongAnimationDuration);
  }

  $: if (win) {
    playWinAnimation();
  }

  export function playWinAnimation() {
    tick().then(() => {
      leftSide.scrollToBottom();
      rightSide.scrollToBottom();
    });

    setTimeout(() => {
      const leftGuessClone = leftLastGuess.cloneNode(true);
      const rightGuessClone = rightLastGuess.cloneNode(true);

      leftLastGuess.style.visibility = "hidden";
      rightLastGuess.style.visibility = "hidden";

      const leftRect = leftLastGuess.getBoundingClientRect();
      const rightRect = rightLastGuess.getBoundingClientRect();

      leftGuessClone.style.position = "absolute";
      leftGuessClone.style.top = leftRect.top + "px";
      leftGuessClone.style.left = leftRect.left + "px";
      leftGuessClone.style.zIndex = "1000";
      leftGuessClone.style.transition = `transform ${winAnimationDuration[1]}ms cubic-bezier(.9,0,1,1)`;

      rightGuessClone.style.position = "absolute";
      rightGuessClone.style.top = rightRect.top + "px";
      rightGuessClone.style.left = rightRect.left + "px";
      rightGuessClone.style.transition = `transform ${winAnimationDuration[1]}ms cubic-bezier(.9,0,1,1)`;

      document.body.appendChild(leftGuessClone);
      document.body.appendChild(rightGuessClone);

      const target = winTarget.getBoundingClientRect();

      const leftCloneRect = leftGuessClone.getBoundingClientRect();
      const rightCloneRect = rightGuessClone.getBoundingClientRect();

      leftGuessClone.style.transform = `
          translateX(${target.left - leftCloneRect.left}px)
          translateY(${target.top - leftCloneRect.top}px)
        `;

      rightGuessClone.style.transform = `
          translateX(${target.left - rightCloneRect.left}px)
          translateY(${target.top - rightCloneRect.top}px)
        `;

      setTimeout(() => {
        leftGuessClone.remove();
        rightGuessClone.remove();
        winTarget.style.visibility = "visible";
      }, winAnimationDuration[1]);
    }, winAnimationDuration[0]);
  }
</script>

<div class="flex justify-between items-center w-full max-w-xl">
  <PlayerSide
    class="flex-1"
    name={leftName}
    guesses={leftHistory}
    bind:this={leftSide}
    bind:lastGuess={leftLastGuess}
  >
    {#if leftReady}
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="currentColor"
        class="my-3 text-green-500 size-8"
      >
        <path
          fill-rule="evenodd"
          d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm13.36-1.814a.75.75 0 1 0-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 0 0-1.06 1.06l2.25 2.25a.75.75 0 0 0 1.14-.094l3.75-5.25Z"
          clip-rule="evenodd"
        />
      </svg>
    {:else if !wrongAnimation && !win}
      <div class="my-6">
        <Thinking />
      </div>
    {/if}
  </PlayerSide>
  {#if wrongAnimation}
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="2"
      stroke="currentColor"
      class="self-center text-red-500 size-10"
      in:fly={{ y: -100, duration: wrongAnimationDuration / 2 }}
      out:fly={{ y: 100, duration: wrongAnimationDuration / 2 }}
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M6 18 18 6M6 6l12 12"
      />
    </svg>
  {/if}

  {#if win}
    <div class="flex relative justify-center items-center">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="currentColor"
        class="absolute mb-32 text-yellow-500 size-12"
        in:fly={{
          y: 64,
          duration: winAnimationDuration[2],
          delay: winAnimationDuration[0] + winAnimationDuration[1],
        }}
      >
        <path
          fill-rule="evenodd"
          d="M5.166 2.621v.858c-1.035.148-2.059.33-3.071.543a.75.75 0 0 0-.584.859 6.753 6.753 0 0 0 6.138 5.6 6.73 6.73 0 0 0 2.743 1.346A6.707 6.707 0 0 1 9.279 15H8.54c-1.036 0-1.875.84-1.875 1.875V19.5h-.75a2.25 2.25 0 0 0-2.25 2.25c0 .414.336.75.75.75h15a.75.75 0 0 0 .75-.75 2.25 2.25 0 0 0-2.25-2.25h-.75v-2.625c0-1.036-.84-1.875-1.875-1.875h-.739a6.706 6.706 0 0 1-1.112-3.173 6.73 6.73 0 0 0 2.743-1.347 6.753 6.753 0 0 0 6.139-5.6.75.75 0 0 0-.585-.858 47.077 47.077 0 0 0-3.07-.543V2.62a.75.75 0 0 0-.658-.744 49.22 49.22 0 0 0-6.093-.377c-2.063 0-4.096.128-6.093.377a.75.75 0 0 0-.657.744Zm0 2.629c0 1.196.312 2.32.857 3.294A5.266 5.266 0 0 1 3.16 5.337a45.6 45.6 0 0 1 2.006-.343v.256Zm13.5 0v-.256c.674.1 1.343.214 2.006.343a5.265 5.265 0 0 1-2.863 3.207 6.72 6.72 0 0 0 .857-3.294Z"
          clip-rule="evenodd"
        />
      </svg>

      <div class="invisible text-2xl whitespace-nowrap" bind:this={winTarget}>
        {leftHistory[0]}
      </div>
    </div>
  {/if}

  <PlayerSide
    class="flex-1"
    name={rightName}
    guesses={rightHistory}
    right
    bind:this={rightSide}
    bind:lastGuess={rightLastGuess}
  >
    {#if rightReady}
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="currentColor"
        class="my-3 text-green-500 size-8"
      >
        <path
          fill-rule="evenodd"
          d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm13.36-1.814a.75.75 0 1 0-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 0 0-1.06 1.06l2.25 2.25a.75.75 0 0 0 1.14-.094l3.75-5.25Z"
          clip-rule="evenodd"
        />
      </svg>
    {:else if !wrongAnimation && !win}
      <div class="my-6">
        <Thinking />
      </div>
    {/if}
  </PlayerSide>
</div>
