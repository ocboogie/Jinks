<template>
  <div class="lobby">
    <h3>Waiting for a player</h3>
    <spinner />
  </div>
</template>
<script>
import Spinner from "../components/LoadingSpinner.vue";

export default {
  components: {
    Spinner
  }
};
</script>

<style lang="scss" scoped>
.lobby {
  text-align: center;
}
</style>
