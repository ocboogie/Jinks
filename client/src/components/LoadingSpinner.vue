<template>
  <div class="spinners">
    <div class="spinner-1" />
    <div class="spinner-2" />
    <div class="spinner-3" />
  </div>
</template>
<style lang="scss" scoped>
.spinners > * {
  border-radius: 100%;
  display: inline-block;
  animation: fade-in-out 1s linear infinite;
  background: lighten(black, 70%);
  width: 10px;
  height: 10px;
  &.spinner-2 {
    margin: 0px 0.5rem;
    animation-delay: 0.3333s;
  }
  &.spinner-3 {
    animation-delay: 0.6666s;
  }
}
@keyframes fade-in-out {
  0% {
    opacity: 1;
  }
  50%,
  80% {
    opacity: 0;
  }
  100% {
    opacity: 1;
  }
}
</style>
