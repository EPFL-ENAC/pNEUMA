<template>
  <div @dblclick="onReset">
    <v-range-slider
      ref="rangeSlider"
      v-model="testValue"
      strict
      hide-details
      :min="min"
      :max="max"
      :step="step"
    >
    </v-range-slider>
    <v-icon
      ref="dragIcon"
      class="drag-icon"
      :icon="mdiDragVariant"
      @mousedown="startDrag"
      @mouseup="stopDrag"
      @touchstart="startDrag"
      @touchend="stopDrag"
    />
  </div>
</template>

<script setup lang="ts">
import { mdiDragVariant } from '@mdi/js'
import { computed, defineModel, onMounted, ref, watch } from 'vue'
import type { VIcon, VRangeSlider } from 'vuetify/components'
import { throttle } from 'lodash'

const props = defineProps<{
  min: number
  max: number
  step?: number
}>()

const testValue = defineModel<[number, number]>({ required: true })

const rangeSlider = ref<VRangeSlider | null>(null)
const dragIcon = ref<VIcon | null>(null)

const isDragging = ref(false)

const initialMousePosition = ref<number>(0)
const initialSliderMin = ref<number>(0)
const initialSliderMax = ref<number>(0)

function startDrag(ev: MouseEvent | TouchEvent) {
  isDragging.value = true
  initialMousePosition.value = 'touches' in ev ? ev.touches[0].clientX : ev.clientX
  initialSliderMin.value = testValue.value[0]
  initialSliderMax.value = testValue.value[1]
}

function onReset() {
  testValue.value = [props.min, props.max]
}

function stopDrag() {
  isDragging.value = false
}

const sliderWidth = computed(() => {
  return rangeSlider?.value?.$el.clientWidth // 16px is the margin of the slider
})

const iconWidth = computed(() => {
  return dragIcon?.value?.$el.clientWidth
})

watch(testValue, (newVal) => {
  const mid = (newVal[0] + newVal[1]) / 2
  const initialRange = props.max - props.min
  const ratio = sliderWidth.value / initialRange

  setIconDragPosition(mid * ratio)
})

const setIconDragPosition = (position?: number) => {
  if (position === undefined) {
    const mid = (testValue.value[0] + testValue.value[1]) / 2
    const initialRange = props.max - props.min
    const ratio = sliderWidth.value / initialRange
    position = mid * ratio
  }
  if (dragIcon.value) {
    dragIcon.value.$el.style.left = `${8 + (position - iconWidth.value / 2)}px`
  }
}

onMounted(() => {
  setIconDragPosition()
})

const handleDragThrottled = throttle(handleDrag, 50)

watch(isDragging, (newVal) => {
  if (newVal) {
    document.addEventListener('mousemove', handleDragThrottled)
    document.addEventListener('mouseup', stopDrag)
    document.addEventListener('touchmove', handleDragThrottled)
    document.addEventListener('touchend', stopDrag)
  } else {
    document.removeEventListener('mousemove', handleDragThrottled)
    document.removeEventListener('mouseup', stopDrag)
    document.removeEventListener('touchmove', handleDragThrottled)
    document.removeEventListener('touchend', stopDrag)
  }
})

function handleDrag(ev: MouseEvent | TouchEvent) {
  const currentPosition = 'touches' in ev ? ev.touches[0].clientX : ev.clientX
  const sliderElement = rangeSlider.value?.$el

  if (!sliderElement) return

  const mouseMoveDistance = currentPosition - initialMousePosition.value

  const valueRange = props.max - props.min
  const diffValue = (mouseMoveDistance / sliderWidth.value) * valueRange

  const step = props.step || 1
  const moveValue = Math.round(diffValue / step) * step
  let newMin = initialSliderMin.value + moveValue
  let newMax = initialSliderMax.value + moveValue

  if (newMin < props.min || newMax > props.max) return

  if (newMin != testValue.value[0] || newMax != testValue.value[1]) {
    testValue.value = [newMin, newMax]
  }
}
</script>

<style scoped>
.drag-icon {
  cursor: pointer;
  position: relative;
}
</style>
