<script>
  import { afterUpdate, onMount, tick } from "svelte";

  export let right = false;
  export let name;
  export let guesses = [];

  export let lastGuess;

  let guessContainer;
  let guessElems = [];
  let slotContainer;

  const guessContainerHeight = 224;

  let bottomPadding = 0;
  let topPadding = 0;

  function getItemElems() {
    if (slotContainer && slotContainer.children.length > 0) {
      return guessElems.concat(slotContainer);
    } else {
      return guessElems;
    }
  }

  $: {
    lastGuess = guessElems[guessElems.length - 1];
  }

  function updateItems() {
    const itemElems = getItemElems();

    if (itemElems.length > 0) {
      topPadding =
        (guessContainerHeight - itemElems[0].getBoundingClientRect().height) /
        2;
      bottomPadding =
        (guessContainerHeight -
          itemElems[itemElems.length - 1].getBoundingClientRect().height) /
        2;
    }

    const containerRect = guessContainer.getBoundingClientRect();
    const containerMiddleY = containerRect.top + containerRect.height / 2;

    itemElems.forEach((itemElem) => {
      const rect = itemElem.getBoundingClientRect();
      const middleY = rect.top + rect.height / 2;

      const distance = Math.abs(containerMiddleY - middleY);

      const alpha = distance / guessContainerHeight;

      const opacity = 1 / (alpha + 1) ** 2;
      const scale = 1 / (alpha + 1) ** 2;

      itemElem.style.opacity = opacity;
      itemElem.style.transform = `scale(${scale})`;
    });
  }

  afterUpdate(() => {
    updateItems();
  });

  onMount(() => {
    updateItems();
  });

  export function scrollToBottom() {
    guessContainer.scrollTo({
      left: 0,
      top: guessContainer.scrollHeight,
      behavior: "smooth",
    });
  }
</script>

<div class="flex {$$props.class}" class:flex-row-reverse={right}>
  <div
    class="flex justify-center items-center py-6 px-3 text-xl"
    class:border-r={!right}
    class:border-l={right}
  >
    {name}
  </div>
  <div
    class:pl-3={!right}
    class:pr-3={right}
    class:justify-end={right}
    class:justify-start={!right}
    class="flex relative flex-1"
  >
    <div
      class="overflow-y-auto flex-1"
      style="{right
        ? 'direction: rtl;'
        : ''} max-height: {guessContainerHeight}px"
      bind:this={guessContainer}
      on:scroll={updateItems}
    >
      <div
        class="flex flex-col justify-center text-base"
        class:items-start={!right}
        class:items-end={right}
        class:pr-6={!right}
        class:pl-6={right}
        style="direction: ltr; padding-top: {topPadding}px; padding-bottom: {bottomPadding}px;"
      >
        {#if guesses.length > 0}
          {#each guesses.reverse() as guess, i}
            <div
              bind:this={guessElems[i]}
              class="text-2xl whitespace-nowrap origin-left"
              class:origin-left={!right}
              class:origin-right={right}
              class:mb-1={i != guesses.length - 1}
            >
              {guess}
            </div>
          {/each}
        {/if}
        {#if $$slots.default}
          <div
            bind:this={slotContainer}
            class:origin-left={!right}
            class:origin-right={right}
          >
            <slot />
          </div>
        {/if}
      </div>
    </div>
  </div>
</div>
