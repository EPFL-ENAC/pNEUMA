<template>
  <div class="pb-8">
    <div id="slider-round" ref="sliderHTML" class="slider-styled" />
  </div>
</template>

<script setup lang="ts">
import { mdiDragVariant } from '@mdi/js'
import noUiSlider from 'nouislider'

import { PipsMode, type API, type PipsType } from 'nouislider'
import 'nouislider/dist/nouislider.css'

import { computed, defineModel, onMounted, ref, watch } from 'vue'
import type { VIcon, VRangeSlider } from 'vuetify/components'
import { throttle } from 'lodash'
import test from 'node:test'

const props = defineProps<{
  min: number
  max: number
  step?: number
  startDate?: Date
}>()

const slider = ref<API | null>(null)

const sliderHTML = ref<HTMLDivElement | null>(null)

const formatter = {
  to: (value: number) => {
    const date = new Date((props.startDate?.getTime() || 0) + value)
    // console.log(value, props.startDate?.getTime(), date.getMinutes())
    return `${date.getHours()}:${date.getMinutes()}`
  },
  from: (value: string) => {
    // console.log(value)
    return Number(value)
  }
}

const formatterTooltip = {
  to: (value: number) => {
    const date = new Date((props.startDate?.getTime() || 0) + value)
    // console.log(value, props.startDate?.getTime(), date.getMinutes())
    return `${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`
  },
  from: (value: string) => {
    // console.log(value)
    return Number(value)
  }
}

const filterPips = (value: number, type: PipsType) => {
  console.log(value)
  if (value % (1000 * 60 * 10) === 0) return 1
  else if (value % (1000 * 60) === 0) return 2
  else if (value % (1000 * 10) === 0) return 0
  else return -1
}

onMounted(() => {
  if (sliderHTML.value) {
    slider.value = noUiSlider.create(sliderHTML.value, {
      start: [props.min, props.max],
      tooltips: [formatterTooltip, formatterTooltip],
      connect: true,
      behaviour: 'drag',
      step: props.step || 1,
      range: {
        min: props.min,
        max: props.max
      },
      pips: {
        mode: PipsMode.Steps,
        filter: filterPips,
        density: 1000,
        format: formatter
      }
    })

    slider.value.on('update', (values) => {
      testValue.value = values.map(Number) as [number, number]
    })
  }
})

const testValue = defineModel<[number, number]>({ required: true })
</script>

<style scoped>
.drag-icon {
  cursor: pointer;
  position: relative;
}

::v-deep .slider-styled {
  height: 10px;
  padding: 0 7px;
}

::v-deep .noUi-handle:before,
::v-deep .noUi-handle:after {
  display: none;
}

::v-deep .slider-styled .noUi-connect {
  background: rgb(var(--v-theme-surface-variant));
}

::v-deep .slider-styled .noUi-handle {
  height: 18px;
  width: 18px;
  top: -5px;
  right: -9px; /* half the width */
  border-radius: 9px;
}

::v-deep .noUi-tooltip {
  display: none;
}
::v-deep .noUi-active .noUi-tooltip {
  display: block;
}
</style>
