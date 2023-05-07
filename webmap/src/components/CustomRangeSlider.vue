<template>
  <v-range-slider
    ref="rangeSlider"
    v-model="testValue"
    :min="min"
    :max="max"
    v-bind="$attrs"
    @click="onClick"
  >
    <slot></slot>
  </v-range-slider>
</template>

<script setup lang="ts">
import { ref, withDefaults } from 'vue'
import type { VRangeSlider } from 'vuetify/components'

const props = withDefaults(
  defineProps<{
    value?: [number, number]
    min: number
    max: number
  }>(),
  {
    value: () => [0, 0],
    min: 0,
    max: 100
  }
)

const testValue = ref<[number, number]>([0, 10])
const rangeSlider = ref<VRangeSlider | null>(null)

function onClick(ev: MouseEvent) {
  console.log(ev)
}

// watch(testValue, ([nx1, nx2], [ox1, ox2]) => {
//   const diff = nx1 !== ox1 ? nx1 - ox1 : nx2 - ox2
//   console.log('new', nx1, nx2, 'old', ox1, ox2, 'diff', diff)
//   emits('update:modelValue', [ox1 + diff, ox2 + diff])
// })
</script>
