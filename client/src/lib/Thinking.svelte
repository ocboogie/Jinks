<div class="flex gap-2 translate-y-1/2">
  <div class="bg-current rounded-full size-2 animate-[thinking_1s_infinite]" />
  <div
    class="bg-current rounded-full size-2 animate-[thinking_1s_0.15s_infinite]"
  />
  <div
    class="bg-current rounded-full size-2 animate-[thinking_1s_0.3s_infinite]"
  />
</div>

<style global>
  @keyframes -global-thinking {
    0%,
    100% {
      transform: translateY(0);
      animation-timing-function: cubic-bezier(0, 0, 0.2, 1);
    }
    50% {
      transform: translateY(-100%);
      animation-timing-function: cubic-bezier(0.8, 0, 1, 1);
    }
  }
</style>
