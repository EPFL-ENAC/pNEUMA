<template>
  <div class="legend">
    <h4>
      Legend
      <v-btn
        :icon="show ? mdiChevronDown : mdiChevronUp"
        flat
        density="compact"
        @click="show = !show"
      ></v-btn>
    </h4>
    <div v-if="show" class="my-2">
      <!-- Categorical Color Display -->
      <div v-if="!isContinuous">
        <div v-for="item in colors" :key="item.label" class="legend-item">
          <div class="color-box" :style="{ backgroundColor: item.color }"></div>
          <div class="label text-body-2">{{ item.label }}</div>
        </div>
      </div>
      <!-- Continuous Color Ramp -->
      <div v-else class="gradient-ramp">
        <div class="color-ramp"></div>
        <div class="ramp-labels">
          <span>{{ colors[0].label }}</span>
          <span>{{ colors[~~((colors.length - 1) / 2)].label }}</span>
          <span>{{ colors[colors.length - 1].label }}</span>
        </div>
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
  isContinuous?: boolean
}>()
const show = ref(true)

const colors = computed(() => (props.reverse ? [...props.colors].reverse() : props.colors))
const gradientCSS = computed(() => {
  return `linear-gradient(to bottom, ${props.colors.map((c) => c.color).join(', ')})`
})
</script>
<style scoped>
.legend {
  position: absolute;
  bottom: 1em;
  background-color: white;
  padding: 0.6em 1.4em;
  border-radius: 0.3em;
  z-index: 1000;
  right: 2em;
  display: flex;
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

.gradient-ramp {
  display: flex; /* Set display to flex */
  align-items: center; /* Align items vertically */
  width: 100%; /* Full width to accommodate labels next to the ramp */
  height: 150px; /* Adjust height for better gradient visualization */
}

.color-ramp {
  width: 40px; /* Fixed width for the color ramp */
  height: 100%;
  background: v-bind('gradientCSS');
}

.ramp-labels {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: 100%;
  margin-left: 10px; /* Add some spacing between ramp and labels */
}
</style>
