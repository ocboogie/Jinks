<template>
  <button class="base-button">
    <slot />
  </button>
</template>

<style lang="scss" scoped>
.base-button {
  display: inline-block;
  line-height: 1;
  white-space: nowrap;
  cursor: pointer;
  appearance: none;
  text-align: center;
  outline: none;
  transition: 0.1s;
  font-weight: 500;
  user-select: none;
  padding: 12px 20px;
  font-size: 14px;
  border-radius: 4px;

  border: none;
  color: $text-color;
  box-shadow: 0px 2px 20px darken(white, 12.5%);
  background-color: white;

  &:hover,
  &:focus {
    box-shadow: 0px 5px 30px darken(white, 17.5%);
  }

  &:active {
    background: darken(white, 5%);
  }
}
</style>
