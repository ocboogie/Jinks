<template>
  <div class="home">
    <h1>Jinks</h1>
    <base-input class="name-input" placeholder="Name" />
    <base-button class="start-button">
      Began
    </base-button>
  </div>
</template>

<script>
import BaseInput from "../components/BaseInput.vue";
import BaseButton from "../components/BaseButton.vue";

export default {
  components: {
    BaseInput,
    BaseButton
  }
};
</script>
<style lang="scss" scoped>
.home {
  text-align: center;
  .name-input {
    text-align: center;
    margin-bottom: 1rem;
    width: 100px;
  }
  .start-button {
    margin: auto;
    display: block;
  }
}
</style>
