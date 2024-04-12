<script setup lang="ts">
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
    if (selectableItem.selected && 'ids' in selectableItem) {
      const selectableSingleItem = selectableItem as SelectableSingleItem
      return selectableSingleItem.ids
    }
    return []
  }) ?? [])
])

const filterIds = computed<string[]>(() => [
  ...(parameters.value.permanentLayerIds ?? []),
  ...selectedLayerIds.value,
  ...(filterSingleVehicle.value ? ['ghost'] : [])
])

const colorByProgression = ref<boolean>(false)

const filterSingleVehicle = ref<boolean>(false)
const usePreciseTimeRange = ref<boolean>(false)
const heatmapSelection = ref<string>('speed-heatmap')
const vehiclesIds = ref<number[]>([0, 10000])
const timeRange = ref<number[]>([0, 1000])
const preciseTimeRange = ref<number[]>([0, 100])

const preciseTimeRangeSize = computed({
  get() {
    return preciseTimeRange.value[1] - preciseTimeRange.value[0]
  },
  set(newValue) {
    preciseTimeRange.value[1] = preciseTimeRange.value[0] + newValue
  }
})

const preciseTimeRangeMiddle = computed({
  get() {
    return preciseTimeRange.value[0] + ~~(preciseTimeRangeSize.value / 2)
  },
  set(newValue) {
    const halfSize = ~~(preciseTimeRangeSize.value / 2)
    preciseTimeRange.value[0] = newValue - halfSize
    preciseTimeRange.value[1] = newValue + halfSize
  }
})

const speedRange = ref<number[]>([0, 100])
const vehicleId = ref<number>(1)
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
  if (filterSingleVehicle.value) return [['==', ['get', 'id'], vehicleId.value]]
  else return getRangeFilter('id', vehiclesIds.value)
}

const getTypeFilter = (): ExpressionSpecification => {
  return [
    'in',
    ['get', 'vehicle_type'],
    ['literal', selectedTypes.value as ExpressionSpecification]
  ]
}

const getFilter = (): ExpressionSpecification => {
  const filter: ExpressionSpecification = [
    'all',
    getTypeFilter(),
    ...getIdsFilter(),
    ...getRangeFilter('trajectory_start_time', timeRange.value)
    // ...(usePreciseTimeRange.value ? getRangeFilter('time', preciseTimeRange.value) : []),
    // ...getRangeFilter('speed', speedRange.value)
  ]
  return filter
}

watch(
  [
    vehiclesIds,
    filterSingleVehicle,
    vehicleId,
    timeRange,
    preciseTimeRangeMiddle,
    preciseTimeRangeSize,
    speedRange,
    selectedTypes
  ],
  () => {
    if (filterIds.value.includes('vehicles')) map.value?.setFilter('vehicles', getFilter())
    if (filterIds.value.includes('ghost')) map.value?.setFilter('ghost', ['all', ...getIdsFilter()])
    if (filterIds.value.includes('heatmap')) map.value?.setFilter('heatmap', getFilter())
  }
)

const heatmapSourceUrl = computed(() => {
  return `https://pneuma-dev.epfl.ch/tiles/speed_hexmap/{z}/{x}/{y}?vehicle_types=${JSON.stringify(
    selectedTypes.value
  )}&start_time=${JSON.stringify(timeRange.value[0] * 1000)}&end_time=${JSON.stringify(
    timeRange.value[1] * 1000
  )}`
})
watch(heatmapSourceUrl, (newUrl, oldUrl) => {
  if (newUrl !== oldUrl) map.value?.changeSourceTilesUrl('heatmap', newUrl)
})

watch(heatmapSelection, (heatmapSelection: string) => {
  map.value?.setLayerVisibility('density-heatmap', heatmapSelection === 'density-heatmap')
  map.value?.setLayerVisibility('speed-heatmap', heatmapSelection === 'speed-heatmap')
  map.value?.setLayerVisibility('acceleration-heatmap', heatmapSelection === 'acceleration-heatmap')
})

watch(colorByProgression, (colorByProgression) => {
  if (!colorByProgression)
    map.value?.setPaintProperty('vehicles', 'line-color', [
      'match',
      ['get', 'vehicle_type'],
      'Taxi',
      '#ff8c00',
      'Bus',
      '#ff0000',
      'Heavy Vehicle',
      '#483d8b',
      'Medium Vehicle',
      '#32cd32',
      'Motorcycle',
      '#ff69b4',
      'Car',
      '#007cbf',
      '#000000'
    ])
  else
    map.value?.setPaintProperty('vehicles', 'line-color', [
      'interpolate',
      ['linear'],
      ['to-number', ['get', 'avg_speed']],
      0,
      '#00ff00',
      30,
      '#ffff00',
      60,
      '#ff0000'
    ])
})

watch(timeRange, (timeRange) => {
  preciseTimeRange.value[0] = Math.max(preciseTimeRange.value[0], timeRange[0])
  preciseTimeRange.value[1] = Math.min(preciseTimeRange.value[1], timeRange[1])
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
              <v-card-title> Time range in seconds </v-card-title>
              <v-card-text>
                <v-range-slider
                  v-model="timeRange"
                  hide-details
                  :min="0"
                  :max="800"
                  :step="60"
                  strict
                  density="compact"
                  thumb-label
                ></v-range-slider>
              </v-card-text>
            </v-card>
            <v-card>
              <v-card-title>Color encoding</v-card-title>
              <v-card-text>
                <v-radio-group v-model="heatmapSelection">
                  <v-radio label="Density" value="density-heatmap"></v-radio>
                  <v-radio label="Speed" value="speed-heatmap"></v-radio>
                  <v-radio label="Acceleration" value="acceleration-heatmap"></v-radio>
                </v-radio-group>
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
          :max-zoom="19"
          :min-zoom="14"
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
