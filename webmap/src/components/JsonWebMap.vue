<script setup lang="ts">
import LayerSelector from '@/components/LayerSelector.vue'
import MapLibreMap from '@/components/MapLibreMap.vue'
import type { Parameters } from '@/utils/jsonWebMap'
import type { SelectableSingleItem } from '@/utils/layerSelector'
import axios from 'axios'
import type { ExpressionSpecification } from 'maplibre-gl'
import { computed, ref, shallowRef, triggerRef, watch } from 'vue'

const props = defineProps<{
  styleUrl: string
  parametersUrl: string
}>()

const map = ref<InstanceType<typeof MapLibreMap>>()

const parameters = shallowRef<Parameters>({})
const selectedLayerIds = ref<string[]>([
  ...(parameters.value?.selectableItems?.flatMap((selectableItem) => {
    if (selectableItem.selected && Object.hasOwn(selectableItem, 'ids')) {
      const selectableSingleItem = selectableItem as SelectableSingleItem
      return selectableSingleItem.ids
    }
    return []
  }) ?? [])
])

const filterIds = computed<string[]>(() => [
  ...(parameters.value.permanentLayerIds ?? []),
  ...selectedLayerIds.value
])

const filterSingleVehicle = ref<boolean>(false)
const fixedTimeRange = ref<boolean>(false)
const vehiclesIds = ref<number[]>([0, 400])
const timeRange = ref<number[]>([0, 1000])
const timeRangeMiddle = computed({
  get() {
    return timeRange.value[0] + ~~((timeRange.value[1] - timeRange.value[0]) / 2)
  },
  set(newValue) {
    const halfSize = ~~(timeRangeSize.value / 2)
    timeRange.value[0] = newValue - halfSize
    timeRange.value[1] = newValue + halfSize
  }
})
const timeRangeSize = computed({
  get() {
    return timeRange.value[1] - timeRange.value[0]
  },
  set(newValue) {
    timeRange.value[1] = timeRange.value[0] + newValue
  }
})

const speedRange = ref<number[]>([0, 100])
const vehicleId = ref<number>(0)
const vehicleTypes = ['Taxi', 'Bus', 'Heavy Vehicle', 'Medium Vehicle', 'Motorcycle', 'Car']
const selectedTypes = ref<string[]>(vehicleTypes)

const legendItems = computed(() =>
  (parameters.value.selectableItems ?? [])
    .flatMap((item) => ('children' in item ? item.children : item))
    .filter((item) => item.ids.some((id) => filterIds.value.includes(id)))
    .flatMap((item) =>
      item.legend !== undefined
        ? [
            {
              label: item.label,
              legend: item.legend
            }
          ]
        : []
    )
)

watch(
  () => props.parametersUrl,
  (parametersUrl) => {
    axios
      .get<Parameters>(parametersUrl)
      .then((response) => response.data)
      .then((data) => {
        parameters.value = data
        triggerRef(parameters)
        map.value?.update(data.center, data.zoom)
      })
  },
  { immediate: true }
)

const getRangeFilter = (
  name: string,
  range: [number, number] | number[]
): ExpressionSpecification[] => [
  ['>=', ['get', name], range[0]],
  ['<=', ['get', name], range[1]]
]

const getIdsFilter = (): ExpressionSpecification[] => {
  if (filterSingleVehicle.value) return [['==', ['get', 'track_id'], vehicleId.value]]
  else return getRangeFilter('track_id', vehiclesIds.value)
}

const getTypeFilter = (): ExpressionSpecification => {
  return ['in', ['get', 'type'], ['literal', selectedTypes.value as ExpressionSpecification]]
}

const getFilter = (): ExpressionSpecification => {
  const filter: ExpressionSpecification = [
    'all',
    ...getIdsFilter(),
    ...getRangeFilter('time', timeRange.value),
    getTypeFilter(),
    ...getRangeFilter('speed', speedRange.value)
  ]
  return filter
}

watch([vehiclesIds, filterSingleVehicle, vehicleId, timeRange, speedRange, selectedTypes], () => {
  if (filterIds.value.includes('vehicles')) map.value?.setFilter('vehicles', getFilter())
  if (filterIds.value.includes('heatmap')) map.value?.setFilter('heatmap', getFilter())
  // console.log(map.value?.queryFeatures(getFilter()))
})

watch(fixedTimeRange, (fixedTimeRange) => {
  if (fixedTimeRange) {
    timeRangeSize.value = Math.min(timeRangeSize.value, 50)
  }
})

const debounce = (fn: Function, ms = 300) => {
  let timeoutId: ReturnType<typeof setTimeout>
  return function (this: any, ...args: any[]) {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => fn.apply(this, args), ms)
  }
}
</script>

<template>
  <v-container class="fill-height pa-0" fluid>
    <v-row class="fill-height">
      <v-col cols="12" md="3" sm="6" class="pl-6">
        <v-row>
          <v-col>
            <LayerSelector v-model="selectedLayerIds" :items="parameters.selectableItems" />
            <v-card>
              <v-card-title> Vehicle IDs </v-card-title>
              <v-card-text>
                <v-checkbox
                  v-model="filterSingleVehicle"
                  density="compact"
                  hide-details
                  label="Select single vehicle"
                />
                <v-range-slider
                  v-if="!filterSingleVehicle"
                  v-model="vehiclesIds"
                  hide-details
                  :min="0"
                  :max="500"
                  step="1"
                  strict
                  density="compact"
                  thumb-label
                ></v-range-slider>
                <v-slider
                  v-if="filterSingleVehicle"
                  v-model="vehicleId"
                  hide-details
                  :min="0"
                  :max="500"
                  step="1"
                  strict
                  density="compact"
                  thumb-label
                ></v-slider>
              </v-card-text>
            </v-card>
            <v-card>
              <v-card-title> Time range in seconds </v-card-title>
              <v-card-text>
                <v-checkbox
                  v-model="fixedTimeRange"
                  density="compact"
                  hide-details
                  label="Use fixed time range"
                />
                <v-slider
                  v-if="fixedTimeRange"
                  v-model="timeRangeMiddle"
                  hide-details
                  :min="0"
                  :max="1000"
                  :step="1"
                  strict
                  thumb-label="always"
                  label="Time range center"
                >
                  <template #thumb-label="">
                    <span class="thumb-label-nowrap">
                      [ {{ timeRangeMiddle - timeRangeSize }} ,
                      {{ timeRangeMiddle + timeRangeSize }} ]
                    </span>
                  </template>
                </v-slider>
                <v-slider
                  v-if="fixedTimeRange"
                  v-model="timeRangeSize"
                  hide-details
                  :min="0"
                  :max="50"
                  :step="1"
                  strict
                  density="compact"
                  label="Time range size"
                  thumb-label
                ></v-slider>
                <v-range-slider
                  v-if="!fixedTimeRange"
                  v-model="timeRange"
                  hide-details
                  :min="0"
                  :max="1000"
                  :step="1"
                  strict
                  density="compact"
                  thumb-label
                ></v-range-slider>
              </v-card-text>
            </v-card>
            <v-card>
              <v-card-title> Vehicle type </v-card-title>
              <v-card-text>
                <v-checkbox
                  v-for="(item, index) in vehicleTypes"
                  :key="index"
                  v-model="selectedTypes"
                  density="compact"
                  hide-details
                  :label="item"
                  :value="item"
                />
              </v-card-text>
            </v-card>
            <v-card>
              <v-card-title> Speed range in km/h </v-card-title>
              <v-card-text>
                <v-range-slider
                  v-model="speedRange"
                  hide-details
                  :min="0"
                  :max="100"
                  step="1"
                  strict
                  density="compact"
                  thumb-label
                ></v-range-slider>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-divider class="border-opacity-100 mx-n3" />
        <v-row>
          <v-col>
            <v-card title="Legends" flat>
              <v-card-text>
                <v-row>
                  <v-col v-for="(item, index) in legendItems" :key="index" cols="12">
                    <h3>{{ item.label }}</h3>
                    <div>{{ item.legend }}</div>
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-col>
      <v-divider class="border-opacity-100" vertical />
      <v-col cols="12" md="9" sm="6" class="py-0 pl-0">
        <MapLibreMap
          ref="map"
          :center="parameters.center"
          :style-spec="styleUrl"
          :filter-ids="filterIds"
          :popup-layer-ids="parameters.popupLayerIds"
          :zoom="parameters.zoom"
        />
      </v-col>
    </v-row>
  </v-container>
</template>

<style>
.v-slider-thumb__label span.thumb-label-nowrap {
  white-space: nowrap;
}
</style>
