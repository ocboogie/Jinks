<template>
  <input
    :value="value"
    class="base-input"
    @input="$emit('input', $event.target.value)"
  />
</template>
<script>
export default {
  props: {
    value: { type: [String, Number], default: "" }
  }
};
</script>

<style lang="scss" scoped>
.base-input {
  // border-radius: 4px;
  color: $text-color;
  border: none;
  border-bottom: 1px solid $border-color;

  // border: none;
  // box-shadow: 0px 2px 10px black;
  outline: none;
  transition: border-color 0.2s cubic-bezier(0.645, 0.045, 0.355, 1);
  // height: 40px;
  padding: 5px 0px;

  &::placeholder {
    color: $text-placeholder-color;
  }

  // &:hover {
  //   border-color: $text-placeholder-color;
  // }

  &:focus {
    outline: none;
    border-color: $focused-border-color;
  }
}
</style>
