<script context="module">
  import { toast as svelteToast } from "@zerodevx/svelte-toast";

  export function toast(msg) {
    svelteToast.push({
      component: {
        src: ToastInner,
        props: { msg },
      },
    });
  }
</script>

<script>
  import { SvelteToast } from "@zerodevx/svelte-toast";
  import ToastInner from "./ToastInner.svelte";
</script>

<div class="toast-container">
  <SvelteToast />
</div>

<style lang="postcss">
  .toast-container {
    --toastColor: theme("colors.neutral.700");
    --toastBackground: theme("colors.yellow.100");
    --toastBarBackground: theme("colors.yellow.400");
  }
  .toast-container :global(._toastItem) {
    @apply rounded-lg shadow-lg drop-shadow-lg p-5 pl-3 pr-3;
  }
  .toast-container :global(._toastMsg) {
    @apply p-0 flex items-center;
  }
</style>
