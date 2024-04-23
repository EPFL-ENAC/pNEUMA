<script setup lang="ts">
import MapLibreMap from '@/components/MapLibreMap.vue'
import type { Parameters } from '@/utils/jsonWebMap'
import type { SelectableSingleItem } from '@/utils/layerSelector'
import axios from 'axios'
import type { ExpressionSpecification } from 'maplibre-gl'
import { computed, onMounted, ref, shallowRef, triggerRef, watch } from 'vue'

const debounce = (fn: Function, ms = 300) => {
  let timeoutId: ReturnType<typeof setTimeout>
  return function (this: any, ...args: any[]) {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => fn.apply(this, args), ms)
  }
}

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

const heatmapSelection = ref<string>('speed')
const vehiclesIds = ref<number[]>([0, 10000])
const timeRange = ref<number>(1)

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
    ...getIdsFilter()
    // ...getRangeFilter('trajectory_start_time', timeRange.value)
    // ...(usePreciseTimeRange.value ? getRangeFilter('time', preciseTimeRange.value) : []),
    // ...getRangeFilter('speed', speedRange.value)
  ]
  return filter
}

watch([vehiclesIds, filterSingleVehicle, vehicleId, timeRange, speedRange, selectedTypes], () => {
  if (filterIds.value.includes('vehicles')) map.value?.setFilter('vehicles', getFilter())
  if (filterIds.value.includes('ghost')) map.value?.setFilter('ghost', ['all', ...getIdsFilter()])
  if (filterIds.value.includes('heatmap')) map.value?.setFilter('heatmap', getFilter())
})

const baseHeatmapSourceUrl = ref<string>('')
onMounted(() => {
  baseHeatmapSourceUrl.value = map.value?.getSourceTilesUrl('heatmap') ?? ''
})

const createExpressionMaplibre = (minute_start: number, minute_end: number) => {}

watch([timeRange, heatmapSelection], () => {
  const category = heatmapSelection.value
  const propertyName = category + '_' + timeRange.value

  const currentFillColor = map.value?.getPaintProperty(category + '-heatmap', 'fill-color')

  if (currentFillColor && Array.isArray(currentFillColor) && currentFillColor.length > 3) {
    if (category == 'freq')
      currentFillColor[2] = [
        'coalesce',
        ['/', ['to-number', ['get', propertyName]], ['to-number', ['get', 'area']]],
        -1
      ]
    else currentFillColor[2] = ['to-number', ['coalesce', ['get', propertyName], -1]]

    map.value?.setPaintProperty(category + '-heatmap', 'fill-color', currentFillColor)
  }
})

const heatmapSourceUrl = computed(() => {
  // return `https://pneuma-dev.epfl.ch/tiles/speed_hexmap/{z}/{x}/{y}?vehicle_types=${JSON.stringify(
  return baseHeatmapSourceUrl.value + `?vehicle_types=${JSON.stringify(selectedTypes.value)}`
})
watch(heatmapSourceUrl, (newUrl, oldUrl) => {
  if (newUrl !== oldUrl) map.value?.changeSourceTilesUrl('heatmap', newUrl)
})

watch(heatmapSelection, (heatmapSelection: string) => {
  map.value?.setLayerVisibility('freq-heatmap', heatmapSelection === 'freq')
  map.value?.setLayerVisibility('speed-heatmap', heatmapSelection === 'speed')
  map.value?.setLayerVisibility('acceleration-heatmap', heatmapSelection === 'acceleration')
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
                <v-slider
                  v-model="timeRange"
                  hide-details
                  :min="1"
                  :max="14"
                  :step="1"
                  density="compact"
                  thumb-label
                ></v-slider>
              </v-card-text>
            </v-card>
            <v-card>
              <v-card-title>Color encoding</v-card-title>
              <v-card-text>
                <v-radio-group v-model="heatmapSelection">
                  <v-radio label="Density" value="freq"></v-radio>
                  <v-radio label="Speed" value="speed"></v-radio>
                  <v-radio label="Acceleration" value="acceleration"></v-radio>
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
