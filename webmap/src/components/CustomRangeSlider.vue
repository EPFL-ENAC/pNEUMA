<template>
  <div class="pb-8">
    <div class="slider-container">
      <v-btn class="play-button" density="compact" @click="togglePlay" flat>{{
        playing ? 'Pause' : 'Play'
      }}</v-btn>
    </div>
    <div id="slider-round" ref="sliderHTML" class="slider-styled" />
  </div>
</template>

<script setup lang="ts">
import noUiSlider from 'nouislider'

import { PipsMode, type API, type PipsType } from 'nouislider'
import 'nouislider/dist/nouislider.css'

import { defineModel, onUnmounted, onMounted, ref, watch } from 'vue'

const props = defineProps<{
  min: number
  max: number
  step?: number
  startDate?: Date
}>()

const slider = ref<API | null>(null)

const sliderHTML = ref<HTMLDivElement | null>(null)

const testValue = defineModel<[number, number]>({ required: true })

const playing = ref(false)

let playInterval: NodeJS.Timeout | undefined

const updateSlider = () => {
  if (slider.value) {
    slider.value.destroy() // Destroy existing slider instance
  }

  if (sliderHTML.value) {
    slider.value = noUiSlider.create(sliderHTML.value, {
      start: [props.min, props.max],
      tooltips: [formatterTooltip, formatterTooltip],
      connect: true,
      behaviour: 'drag',
      step: props.step || 1,
      range: {
        min: props.min - (props.min % (props.step || 1)),
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
}

const play = () => {
  if (!slider.value || playing.value) return
  playing.value = true
  const [min, max] = (slider.value.get() as [string, string]).map(Number) as [number, number]
  if (max == props.max) {
    const range = max - min
    slider.value.set([props.min, props.min + range])
  }
  playInterval = setInterval(() => {
    if (slider.value) {
      const current = (slider.value.get() as [string, string]).map(Number) as [number, number]
      if (current[1] >= props.max) {
        stop()
      } else {
        slider.value.set([current[0] + (props.step || 1), current[1] + (props.step || 1)])
      }
    }
  }, 250) // Adjust time interval to suit the speed of animation
}

const stop = () => {
  playing.value = false
  if (playInterval) clearInterval(playInterval)
}

const togglePlay = () => {
  if (playing.value) stop()
  else play()
}

onUnmounted(() => {
  if (playInterval) clearInterval(playInterval)
})
// Watch props and update slider accordingly
watch(
  () => [props.min, props.max, props.step],
  () => {
    updateSlider()
  },
  { deep: true }
)

onMounted(() => {
  updateSlider()
})

const formatter = {
  to: (value: number) => {
    const date = new Date((props.startDate?.getTime() || 0) + value)
    const hours = date.getHours().toString()
    const minutes = date.getMinutes().toString().padStart(2, '0')
    return `${hours}:${minutes}`
  },
  from: (value: string) => {
    return Number(value)
  }
}

const formatterTooltip = {
  to: (value: number) => {
    const date = new Date((props.startDate?.getTime() || 0) + value)
    const hours = date.getHours().toString()
    const minutes = date.getMinutes().toString().padStart(2, '0')
    const seconds = date.getSeconds().toString().padStart(2, '0')
    return `${hours}:${minutes}:${seconds}`
  },
  from: (value: string) => Number(value)
}

const filterPips = (value: number, type: PipsType) => {
  if (value % (1000 * 60 * 5) === 0) return 1
  else if (value % (1000 * 60) === 0) return 2
  else if (value % (1000 * 10) === 0) return 0
  else return -1
}
</script>

<style scoped>
.slider-container {
  position: relative;
}

.play-button {
  position: absolute;
  top: -35px;
  right: 0; /* Aligns the button to the top-right corner */
  margin: 0; /* Adjust margin as needed */
}

.slider-styled {
  position: relative;
  width: 100%; /* Ensures the slider expands to fill the container */
  height: 10px;
  padding: 0 7px;
}

.drag-icon {
  cursor: pointer;
  position: relative;
}

:deep() .noUi-value {
  padding-top: 3px;
}

:deep() .noUi-value-sub {
  padding-top: 2px;
}

:deep() .slider-styled {
  height: 10px;
  padding: 0 7px;
}

:deep() .noUi-handle:before,
:deep() .noUi-handle:after {
  display: none;
}

:deep() .slider-styled .noUi-connect {
  background: rgb(var(--v-theme-surface-variant));
}

:deep() .slider-styled .noUi-handle {
  height: 18px;
  width: 18px;
  top: -5px;
  right: -9px; /* half the width */
  border-radius: 9px;
}

:deep() .noUi-touch-area {
  height: 250%;
  width: 250%;
  cursor: move;
  z-index: 1000;
}

:deep() .noUi-handle-lower .noUi-touch-area {
  transform: translate(-50%, -25%);
}
:deep() .noUi-handle-upper .noUi-touch-area {
  transform: translate(0, -25%);
}

:deep() .noUi-tooltip {
  display: none;
}
:deep() .noUi-active .noUi-tooltip {
  display: block;
}
</style>
