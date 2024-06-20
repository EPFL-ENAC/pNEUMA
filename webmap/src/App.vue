<script setup lang="ts">
import { mdiHome, mdiInformation } from '@mdi/js'
import { RouterView } from 'vue-router'
</script>

<template>
  <v-app>
    <v-main>
      <RouterView />
    </v-main>
  </v-app>
</template>

<style lang="scss" scoped>
.v-app-bar {
  border-bottom: 1px solid rgb(var(--v-theme-primary));
}
</style>
