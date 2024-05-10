<script setup lang="ts">
import type { SelectableItem, SelectableSingleItem } from '@/utils/layerSelector'
import { computed, watch } from 'vue'

interface CheckboxProps {
  label: string
  value: string[]
}

const props = withDefaults(
  defineProps<{
    modelValue?: string[]
    items?: SelectableItem[]
  }>(),
  {
    modelValue: () => [],
    items: () => []
  }
)
const emit = defineEmits<{
  (e: 'update:modelValue', value: string[]): void
}>()

const singleItems = computed<SelectableSingleItem[]>(() =>
  props.items.flatMap((item) => {
    if ('children' in item) {
      return item.children
    } else {
      return [item]
    }
  })
)
const items = computed<(CheckboxProps | { label: string; children: CheckboxProps[] })[]>(() =>
  props.items.map((item) =>
    'children' in item
      ? {
          label: item.label,
          children: item.children.map((child) => ({
            label: child.label,
            value: child.ids
          }))
        }
      : {
          label: item.label,
          value: item.ids
        }
  )
)
const selectedItems = computed<string[][]>({
  get: () =>
    singleItems.value
      .map((item) => item.ids)
      .filter((values) => props.modelValue.some((value) => values.includes(value))),
  set: (value) => {
    emit('update:modelValue', value.flat())
  }
})

watch(
  singleItems,
  (value) => {
    emit(
      'update:modelValue',
      value.filter((item) => item.selected).flatMap((item) => item.ids)
    )
  },
  { immediate: true }
)

function selectAll(value: boolean, children: string[][]) {
  if (value) {
    selectedItems.value = [...selectedItems.value, ...children]
  } else {
    selectedItems.value = selectedItems.value.filter((item) => !children.includes(item))
  }
}
</script>

<template>
  <v-card flat>
    <v-card-item>
      <v-card-title class="text-capitalize">Layers</v-card-title>
    </v-card-item>
    <v-expansion-panels multiple variant="accordion">
      <v-expansion-panel v-for="(item, index) in items" :key="index">
        <v-expansion-panel-title v-if="'children' in item">
          <v-checkbox
            color="primary"
            density="compact"
            hide-details
            :indeterminate="
              item.children.some((child) => selectedItems.includes(child.value)) &&
              !item.children.every((child) => selectedItems.includes(child.value))
            "
            :label="item.label"
            :model-value="item.children.every((child) => selectedItems.includes(child.value))"
            @update:model-value="
              selectAll(
                $event !== null ? $event : false,
                item.children.map((child) => child.value)
              )
            "
            @click.stop=""
          >
            <template #label="{ label }">
              <span @click.stop="">{{ label }}</span>
            </template>
          </v-checkbox>
        </v-expansion-panel-title>
        <v-expansion-panel-title v-else collapse-icon="" expand-icon="">
          <v-checkbox
            v-model="selectedItems"
            color="primary"
            density="compact"
            hide-details
            :label="item.label"
            :value="item.value"
          />
        </v-expansion-panel-title>
        <v-expansion-panel-text v-if="'children' in item">
          <v-checkbox
            v-for="(child, childIndex) in item.children"
            :key="childIndex"
            v-model="selectedItems"
            color="primary"
            density="compact"
            hide-details
            :label="child.label"
            :value="child.value"
          >
          </v-checkbox>
        </v-expansion-panel-text>
      </v-expansion-panel>
    </v-expansion-panels>
  </v-card>
</template>
