<template>
  <v-progress-circular
    v-if="loading"
    :size="50"
    :width="5"
    class="progress-circular"
    color="white"
    indeterminate
  ></v-progress-circular>
</template>

<script lang="ts" setup>
const props = defineProps<{
  loading: boolean
}>()
</script>

<style scoped>
.progress-circular {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 10;
}
</style>
