<template>
  <div class="legend">
    <h4>
      Légende
      <v-btn
        :icon="show ? mdiChevronDown : mdiChevronUp"
        flat
        density="compact"
        @click="show = !show"
      ></v-btn>
    </h4>
    <div v-if="show" class="my-2">
      <div v-for="item in colors" :key="item.label" class="legend-item">
        <div class="color-box" :style="{ backgroundColor: item.color }"></div>
        <div class="label text-body-2">{{ item.label }}</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { mdiChevronUp, mdiChevronDown } from '@mdi/js'
import type { LegendColor } from '@/utils/legendColor'
const props = defineProps<{
  colors: LegendColor[]
  reverse?: boolean
}>()
const show = ref(true)

const colors = computed(() => (props.reverse ? [...props.colors].reverse() : props.colors))
</script>

<style scoped>
.legend {
  position: absolute;
  bottom: 1em;
  background-color: white;
  padding: 0.6em 1.4em;
  border-radius: 0.3em;
  /* outline: solid 2px black; */
  z-index: 1000;
  right: 2em;
  display: flex;
  justify-content: space-between;
  flex-direction: column;
  align-items: flex-start;
  color: rgba(var(--v-theme-primary), var(--v-medium-emphasis-opacity));
}

.legend-item {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
  width: 100%;
}

.color-box {
  width: 40px;
  height: 25px;
  margin-right: 8px;
}

.label,
.code {
  margin-right: 8px;
}
</style>
